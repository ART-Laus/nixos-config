#!/usr/bin/env python3
import json
import math
import os
import queue
import signal
import subprocess
import sys
import threading
import time
import psutil

MAX_CMDLINE = 512
START_EPSILON = 0.05
CRITICAL_NAMES = {
    "systemd",
    "init",
    "hyprland",
    "kwin_wayland",
    "quickshell",
    "wayland",
    "weston",
    "pipewire",
    "wireplumber",
    "xorg",
    "xwayland",
    "dbus-daemon",
    "dbus-broker",
    "networkmanager",
    "login",
    "sshd",
}
CRITICAL_PREFIXES = (
    "systemd-",
    "pipewire-",
    "wireplumber-",
    "dbus-",
    "wayland-",
    "xwayland-",
    "sshd-",
    "networkmanager-",
)
SIGNAL_MAP = {
    "TERM": signal.SIGTERM,
    "KILL": signal.SIGKILL,
    "STOP": signal.SIGSTOP,
    "CONT": signal.SIGCONT,
}
PS_ANY = (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess, OSError)
PS_ACCESS = (psutil.AccessDenied, OSError)

STOP = False
WAKE_QUEUE = None


def _safe_str(value, default=""):
    try:
        return str(value)
    except Exception:
        return default


def _safe_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError, OverflowError):
        return default


def _safe_float(value, default=0.0):
    try:
        result = float(value)
    except (TypeError, ValueError, OverflowError):
        return default
    return result if math.isfinite(result) else default


def _sanitize_cmdline(argv):
    if isinstance(argv, str):
        iterable = [argv]
    else:
        try:
            iterable = list(argv)
        except TypeError:
            iterable = [argv]
    parts = []
    for item in iterable:
        text = "".join(ch if ch.isprintable() else " " for ch in _safe_str(item))
        text = text.strip()
        if text:
            parts.append(text)
    text = " ".join(parts)
    if len(text) > MAX_CMDLINE:
        text = text[: MAX_CMDLINE - 3].rstrip() + "..."
    return text


def _result(ok, op, message, pid=None, **extra):
    result = {
        "type": "result",
        "ok": bool(ok),
        "op": _safe_str(op),
        "message": _safe_str(message),
    }
    if pid is not None:
        result["pid"] = _safe_int(pid, 0)
    result.update(extra)
    return result


def emit(obj):
    try:
        line = json.dumps(obj, separators=(",", ":"), ensure_ascii=False, allow_nan=False)
    except (TypeError, ValueError):
        return
    try:
        sys.stdout.write(line + "\n")
        sys.stdout.flush()
    except (BrokenPipeError, OSError, ValueError):
        _request_stop()


def emit_result(ok, op, message, pid=None, **extra):
    emit(_result(ok, op, message, pid, **extra))


def _ps_error(op, exc, pid=None):
    if isinstance(exc, psutil.ZombieProcess):
        message = "zombie_process"
    elif isinstance(exc, psutil.NoSuchProcess):
        message = "no_such_process"
    elif isinstance(exc, psutil.AccessDenied):
        message = "access_denied"
    elif isinstance(exc, OSError):
        message = "os_error"
    else:
        message = "psutil_error"
    detail = _safe_str(exc)
    if detail:
        message += ": " + detail[:200]
    emit_result(False, op, message, pid)


def _resolve_cwd(value):
    if value is None or value == "":
        return True, None
    if not isinstance(value, str):
        return False, None
    if not os.path.isdir(value):
        return False, None
    return True, value


def _is_critical(pid, proc, name):
    if pid in (0, 1):
        return True
    candidates = [_safe_str(name).strip().lower().strip("[]")]
    for getter in (proc.cmdline, proc.exe):
        try:
            value = getter()
        except PS_ANY:
            continue
        if value:
            if isinstance(value, (list, tuple)):
                value = value[0] if value else ""
            candidates.append(os.path.basename(_safe_str(value)).strip().lower().strip("[]"))
    for candidate in candidates:
        if not candidate:
            continue
        base = os.path.basename(candidate)
        if base in CRITICAL_NAMES:
            return True
        if base.startswith(CRITICAL_PREFIXES):
            return True
    return False


def _is_kernel_thread(pid, ppid, name, cmdline):
    normalized = _safe_str(name).strip()
    if normalized.startswith("[") and normalized.endswith("]"):
        return True
    if pid <= 2:
        return pid != 1
    if ppid in (0, 2) and not cmdline:
        return True
    return False


def _request_stop():
    global STOP
    STOP = True
    if WAKE_QUEUE is not None:
        try:
            WAKE_QUEUE.put_nowait(None)
        except queue.Full:
            pass


def _stop_handler(signum, frame):
    _request_stop()


def _stdin_reader(command_queue):
    while True:
        try:
            line = sys.stdin.readline()
        except (OSError, ValueError):
            command_queue.put(None)
            return
        if line == "":
            command_queue.put(None)
            return
        command_queue.put(line)


class Backend:
    def __init__(self):
        self.interval = 1.5
        self.running = False
        self.next_snapshot = None
        self._procs = {}

    def handle(self, obj):
        if not isinstance(obj, dict):
            emit_result(False, "command", "expected_json_object")
            return
        cmd = obj.get("cmd")
        if cmd == "snapshot":
            self._cmd_snapshot(obj)
        elif cmd == "pause":
            self._cmd_pause()
        elif cmd == "resume":
            self._cmd_resume()
        elif cmd == "signal":
            self._cmd_signal(obj)
        elif cmd == "start":
            self._cmd_start(obj)
        elif cmd == "start_shell":
            self._cmd_start_shell(obj)
        elif cmd == "quit":
            self._cmd_quit()
        else:
            emit_result(False, "command", "unknown_command")

    def _cmd_snapshot(self, obj):
        if "interval" in obj:
            interval = _safe_float(obj.get("interval"), -1.0)
            if interval <= 0.0 or interval > 86400.0:
                emit_result(False, "snapshot", "invalid_interval")
                return
            self.interval = interval
        if obj.get("once") is True:
            self.emit_snapshot()
            if self.running and self.next_snapshot is None:
                self.next_snapshot = time.monotonic() + self.interval
            emit_result(True, "snapshot", "snapshot_sent")
            return
        self.running = True
        self.next_snapshot = time.monotonic()
        self.emit_snapshot()
        self.next_snapshot = time.monotonic() + self.interval
        emit_result(True, "snapshot", "snapshot_started")

    def _cmd_pause(self):
        self.running = False
        self.next_snapshot = None
        emit_result(True, "pause", "paused")

    def _cmd_resume(self):
        self.running = True
        self.next_snapshot = time.monotonic()
        self.emit_snapshot()
        self.next_snapshot = time.monotonic() + self.interval
        emit_result(True, "resume", "resumed")

    def _cmd_signal(self, obj):
        raw_pid = obj.get("pid")
        if isinstance(raw_pid, bool):
            emit_result(False, "signal", "invalid_pid")
            return
        pid = _safe_int(raw_pid, -1)
        if pid <= 0:
            emit_result(False, "signal", "invalid_pid")
            return
        start_time = _safe_float(obj.get("start_time"), -1.0)
        if start_time <= 0.0:
            emit_result(False, "signal", "invalid_start_time", pid)
            return
        sig_name = _safe_str(obj.get("sig")).strip().upper()
        if sig_name.startswith("SIG"):
            sig_name = sig_name[3:]
        sig = SIGNAL_MAP.get(sig_name)
        if sig is None:
            emit_result(False, "signal", "unknown_signal", pid)
            return
        if pid == os.getpid() or pid == os.getppid():
            emit_result(False, "signal", "refusing_to_signal_self_or_parent", pid)
            return
        try:
            proc = psutil.Process(pid)
        except PS_ANY as exc:
            _ps_error("signal", exc, pid)
            return
        try:
            create_time = _safe_float(proc.create_time(), -1.0)
        except PS_ANY as exc:
            _ps_error("signal", exc, pid)
            return
        if abs(create_time - start_time) > START_EPSILON:
            emit_result(False, "signal", "pid_reused_or_gone", pid)
            return
        try:
            name = _safe_str(proc.name())
        except PS_ANY as exc:
            _ps_error("signal", exc, pid)
            return
        if _is_critical(pid, proc, name) and obj.get("acknowledge_critical") is not True:
            emit_result(False, "signal", "critical_process_requires_confirmation", pid, need_confirm=True, name=name)
            return
        try:
            proc.send_signal(sig)
        except PS_ANY as exc:
            _ps_error("signal", exc, pid)
            return
        emit_result(True, "signal", "signal_sent", pid, sig=sig_name, name=name)

    def _cmd_start(self, obj):
        raw_argv = obj.get("argv")
        if not isinstance(raw_argv, (list, tuple)) or not raw_argv:
            emit_result(False, "start", "invalid_argv")
            return
        argv = [_safe_str(item) for item in raw_argv]
        if not argv[0]:
            emit_result(False, "start", "invalid_argv")
            return
        ok, cwd = _resolve_cwd(obj.get("cwd"))
        if not ok:
            emit_result(False, "start", "invalid_cwd")
            return
        try:
            proc = subprocess.Popen(
                argv,
                shell=False,
                cwd=cwd,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                close_fds=True,
                start_new_session=True,
            )
        except (OSError, ValueError, TypeError) as exc:
            emit_result(False, "start", "spawn_failed: " + _safe_str(exc)[:240])
            return
        emit_result(True, "start", "started", proc.pid, argv=_sanitize_cmdline(argv))

    def _cmd_start_shell(self, obj):
        command = obj.get("command")
        if not isinstance(command, str) or not command.strip():
            emit_result(False, "start_shell", "invalid_command")
            return
        ok, cwd = _resolve_cwd(obj.get("cwd"))
        if not ok:
            emit_result(False, "start_shell", "invalid_cwd")
            return
        try:
            proc = subprocess.Popen(
                command,
                shell=True,
                cwd=cwd,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                close_fds=True,
                start_new_session=True,
            )
        except (OSError, ValueError, TypeError) as exc:
            emit_result(False, "start_shell", "spawn_failed: " + _safe_str(exc)[:240])
            return
        emit_result(True, "start_shell", "started", proc.pid, command=_sanitize_cmdline(command))

    def _cmd_quit(self):
        emit_result(True, "quit", "quitting")
        _request_stop()

    def emit_snapshot(self):
        emit({"type": "snapshot", "totals": self._totals(), "processes": self._processes()})

    def _totals(self):
        try:
            cpu = _safe_float(psutil.cpu_percent(interval=None))
        except PS_ANY:
            cpu = 0.0
        try:
            virtual = psutil.virtual_memory()
            memory_total = _safe_int(virtual.total)
            memory_used = _safe_int(virtual.used)
            memory_percent = _safe_float(virtual.percent)
        except PS_ANY:
            memory_total = 0
            memory_used = 0
            memory_percent = 0.0
        try:
            swap = psutil.swap_memory()
            swap_total = _safe_int(swap.total)
            swap_used = _safe_int(swap.used)
            swap_percent = _safe_float(swap.percent)
        except PS_ANY:
            swap_total = 0
            swap_used = 0
            swap_percent = 0.0
        try:
            load = [_safe_float(value) for value in os.getloadavg()]
        except (OSError, AttributeError, ValueError):
            load = []
        while len(load) < 3:
            load.append(0.0)
        return {
            "cpu_percent": cpu,
            "memory_used": memory_used,
            "memory_total": memory_total,
            "memory_percent": memory_percent,
            "swap_used": swap_used,
            "swap_total": swap_total,
            "swap_percent": swap_percent,
            "loadavg": load[:3],
        }

    def _processes(self):
        rows = []
        seen = set()
        attrs = ["pid", "ppid", "name", "create_time"]
        try:
            iterator = psutil.process_iter(attrs=attrs, ad_value=None)
        except PS_ANY as exc:
            emit_result(False, "snapshot", _safe_str(exc)[:200])
            return rows
        try:
            for proc in iterator:
                try:
                    info = getattr(proc, "info", {}) or {}
                    pid = _safe_int(info.get("pid", proc.pid), -1)
                    if pid <= 0:
                        continue
                    ppid = _safe_int(info.get("ppid"), 0)
                    create_time = _safe_float(info.get("create_time"), 0.0)
                    if create_time <= 0.0:
                        create_time = _safe_float(proc.create_time(), 0.0)
                    if create_time <= 0.0:
                        continue
                except PS_ANY:
                    continue

                cached = self._procs.get(pid)
                reused = cached is None or abs(cached[1] - create_time) > START_EPSILON
                row_proc = proc if reused else cached[0]

                try:
                    raw_name = info.get("name")
                    name = _safe_str(raw_name if raw_name else row_proc.name())
                except psutil.NoSuchProcess:
                    continue
                except PS_ANY:
                    name = ""

                try:
                    raw_cmdline = row_proc.cmdline()
                except psutil.NoSuchProcess:
                    continue
                except PS_ANY:
                    raw_cmdline = []

                if _is_kernel_thread(pid, ppid, name, raw_cmdline):
                    continue

                if reused:
                    self._procs[pid] = (row_proc, create_time)
                    try:
                        row_proc.cpu_percent(interval=None)
                    except psutil.NoSuchProcess:
                        continue
                    except PS_ANY:
                        pass
                    cpu = 0.0
                else:
                    try:
                        cpu = _safe_float(row_proc.cpu_percent(interval=None))
                    except psutil.NoSuchProcess:
                        continue
                    except PS_ANY:
                        cpu = 0.0

                uid = info.get("uid")
                if isinstance(uid, (tuple, list)):
                    uid = uid[0] if uid else -1
                if uid is None:
                    try:
                        uid = row_proc.uids().real
                    except PS_ANY:
                        uid = -1
                uid = _safe_int(uid, -1)

                try:
                    user = _safe_str(row_proc.username())
                except PS_ANY:
                    user = ""
                try:
                    exe = _safe_str(row_proc.exe())
                except PS_ANY:
                    exe = ""
                try:
                    memory = row_proc.memory_info()
                    memory_rss = _safe_int(memory.rss)
                    memory_vms = _safe_int(memory.vms)
                except psutil.NoSuchProcess:
                    continue
                except PS_ANY:
                    memory_rss = 0
                    memory_vms = 0
                try:
                    memory_percent = _safe_float(row_proc.memory_percent())
                except psutil.NoSuchProcess:
                    continue
                except PS_ANY:
                    memory_percent = 0.0
                try:
                    status = _safe_str(row_proc.status())
                except psutil.NoSuchProcess:
                    continue
                except PS_ANY:
                    status = ""
                try:
                    num_threads = _safe_int(row_proc.num_threads())
                except psutil.NoSuchProcess:
                    continue
                except PS_ANY:
                    num_threads = 0

                cmdline = _sanitize_cmdline(raw_cmdline) or name
                rows.append(
                    {
                        "pid": pid,
                        "ppid": ppid,
                        "uid": uid,
                        "user": user,
                        "name": name,
                        "exe": exe,
                        "cmdline": cmdline,
                        "cpu_percent": cpu,
                        "memory_rss": memory_rss,
                        "memory_vms": memory_vms,
                        "memory_percent": memory_percent,
                        "status": status,
                        "num_threads": num_threads,
                        "create_time": create_time,
                        "start_time": create_time,
                    }
                )
                seen.add(pid)
        except PS_ANY:
            pass
        except (RuntimeError, ValueError):
            pass

        for stale in [pid for pid in self._procs if pid not in seen]:
            self._procs.pop(stale, None)
        return rows


def main():
    global WAKE_QUEUE
    signal.signal(signal.SIGTERM, _stop_handler)
    signal.signal(signal.SIGINT, _stop_handler)
    try:
        psutil.cpu_percent(interval=None)
    except PS_ANY:
        pass
    backend = Backend()
    command_queue = queue.Queue()
    WAKE_QUEUE = command_queue
    threading.Thread(target=_stdin_reader, args=(command_queue,), daemon=True).start()
    emit({"type": "ready", "version": 1})
    while not STOP:
        if backend.running and backend.next_snapshot is not None and time.monotonic() >= backend.next_snapshot:
            try:
                backend.emit_snapshot()
            except Exception as exc:
                emit_result(False, "snapshot", "snapshot_failed: " + _safe_str(exc)[:200])
            backend.next_snapshot = time.monotonic() + backend.interval
            continue
        timeout = None
        if backend.running and backend.next_snapshot is not None:
            timeout = max(0.0, backend.next_snapshot - time.monotonic())
        try:
            item = command_queue.get(timeout=timeout)
        except queue.Empty:
            continue
        if item is None:
            break
        try:
            obj = json.loads(item)
        except (TypeError, ValueError) as exc:
            emit_result(False, "parse", "invalid_json: " + _safe_str(exc)[:200])
            continue
        try:
            backend.handle(obj)
        except Exception as exc:
            emit_result(False, "internal", "internal_error: " + _safe_str(exc)[:200])
        if STOP:
            break
    WAKE_QUEUE = None
    return 0


if __name__ == "__main__":
    sys.exit(main())
