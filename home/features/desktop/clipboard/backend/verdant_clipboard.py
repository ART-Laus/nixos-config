#!/usr/bin/env python3
"""Verdant Clipboard — persistent Wayland clipboard backend.

Three entry points:

  daemon   long running capture/IPC service (started by systemd --user)
  capture  short lived helper invoked by `wl-paste --watch`
  ctl      JSON-lines client over the Unix domain socket

Design notes:
  * clipboard bytes never travel through JSON: capture writes a 0600 temp file
    and only sends its path over IPC;
  * blobs live in $XDG_DATA_HOME/verdant-clipboard, never in XDG_RUNTIME_DIR;
  * the socket lives in XDG_RUNTIME_DIR and is peer-credential checked;
  * sensitive clipboard selections (CLIPBOARD_STATE=sensitive, i.e. the KDE
    password manager marker) and paused privacy mode are never persisted;
  * no content is ever printed to stdout/stderr in daemon/capture mode.
"""

import argparse
import fcntl
import hashlib
import json
import os
import re
import selectors
import signal
import socket
import sqlite3
import struct
import subprocess
import sys
import time
import uuid
from datetime import datetime

import pathlib


# ---------------------------------------------------------------------------
# configuration / paths
# ---------------------------------------------------------------------------

DEFAULTS = {
    "maxEntries": 1000,
    "maxTextBytes": 1024 * 1024,
    "maxImageBytes": 25 * 1024 * 1024,
    "maxOtherBytes": 8 * 1024 * 1024,
    "previewChars": 500,
    "thumbnailPx": 320,
    "captureImages": True,
    "ignoreApps": [],
    "ignorePatterns": [],
    "persistRestore": True,
}
CONFIG_REL = pathlib.Path("verdant-clipboard/config.json")
DATA_REL = pathlib.Path("verdant-clipboard")
RUNTIME_REL = pathlib.Path("verdant-clipboard")

URL_RE = re.compile(r"^(?:https?|ftp|file|magnet)://[^\s]+$", re.I)
EMAIL_RE = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
COLOR_RE = re.compile(r"^(?:#(?:[0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})|(?:rgb|hsl)a?\([^)]+\))$", re.I)
CODE_RE = re.compile(r"(?:^|\n)\s*(?:def |class |fn |let |const |var |import |from |#include|package |function |=>|\{|\}|;)")
FILE_URI_RE = re.compile(r"^file://[^\s]+$")


def config_path():
    base = os.environ.get("XDG_CONFIG_HOME") or str(pathlib.Path.home() / ".config")
    return pathlib.Path(base) / CONFIG_REL


def data_root():
    base = os.environ.get("XDG_DATA_HOME") or str(pathlib.Path.home() / ".local/share")
    return pathlib.Path(base) / DATA_REL


def runtime_root():
    base = os.environ.get("XDG_RUNTIME_DIR") or "/tmp"
    return pathlib.Path(base) / RUNTIME_REL


def db_path():
    return data_root() / "history.sqlite"


def blob_root():
    return data_root() / "blobs"


def thumb_root():
    return data_root() / "thumbs"


def socket_path():
    return runtime_root() / "ipc.sock"


def load_config():
    cfg = dict(DEFAULTS)
    try:
        raw = json.loads(config_path().read_text(encoding="utf-8"))
        if isinstance(raw, dict):
            for key, value in raw.items():
                if key in DEFAULTS:
                    cfg[key] = value
    except (OSError, ValueError):
        pass
    for key in ("maxEntries", "maxTextBytes", "maxImageBytes", "maxOtherBytes", "previewChars", "thumbnailPx"):
        try:
            cfg[key] = max(1, int(cfg[key]))
        except (TypeError, ValueError):
            cfg[key] = DEFAULTS[key]
    for key in ("ignoreApps", "ignorePatterns"):
        if not isinstance(cfg.get(key), list):
            cfg[key] = []
        cfg[key] = [str(v) for v in cfg[key]]
    for key in ("captureImages", "persistRestore"):
        cfg[key] = bool(cfg.get(key))
    return cfg


def ensure_dirs():
    root = data_root()
    for directory in (root, blob_root(), thumb_root(), runtime_root(), runtime_root() / "incoming"):
        directory.mkdir(parents=True, exist_ok=True, mode=0o700)
        try:
            directory.chmod(0o700)
        except OSError:
            pass


# ---------------------------------------------------------------------------
# content sniffing / classification
# ---------------------------------------------------------------------------

def sniff(data, source="default"):
    """Return (mime, kind, text_or_None). Never mutates the original bytes."""
    head = data[:512]
    if head.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png", "image", None
    if head.startswith(b"\xff\xd8\xff"):
        return "image/jpeg", "image", None
    if head.startswith((b"GIF87a", b"GIF89a")):
        return "image/gif", "image", None
    if head.startswith(b"RIFF") and head[8:12] == b"WEBP":
        return "image/webp", "image", None
    if head.startswith(b"BM"):
        return "image/bmp", "image", None
    if head.startswith(b"%PDF-"):
        return "application/pdf", "file", None
    if b"<svg" in head.lower():
        return "image/svg+xml", "image", None
    allowed_control = b"\t\n\r\f\v"
    if any(byte < 0x20 and byte not in allowed_control for byte in head):
        return "application/octet-stream", "other", None
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        return "application/octet-stream", "other", None
    stripped = text.strip()
    low = stripped[:256].lower()
    if low.startswith("<!doctype html") or low.startswith("<html") or low.startswith("<meta http-equiv"):
        return "text/html", "html", text
    if FILE_URI_RE.match(stripped):
        return "text/uri-list", "file", text
    if URL_RE.match(stripped):
        return "text/plain;charset=utf-8", "url", text
    if EMAIL_RE.match(stripped):
        return "text/plain;charset=utf-8", "email", text
    if COLOR_RE.match(stripped):
        return "text/plain;charset=utf-8", "color", text
    if stripped[:1] in ("{", "[") and len(stripped) > 1:
        try:
            json.loads(stripped)
            return "text/plain;charset=utf-8", "json", text
        except ValueError:
            pass
    if CODE_RE.search(text) and len(text) > 8:
        return "text/plain;charset=utf-8", "code", text
    return "text/plain;charset=utf-8", "text", text


def preview_for(text, limit):
    if text is None:
        return ""
    collapsed = " ".join(text.splitlines())
    if len(collapsed) > limit:
        return collapsed[:limit] + "…"
    return collapsed


def domain_of(text):
    match = re.match(r"^[a-z]+://([^/]+)", text or "", re.I)
    return match.group(1).lower() if match else ""


def group_of(ts):
    now = datetime.now()
    midnight = now.replace(hour=0, minute=0, second=0, microsecond=0).timestamp()
    if ts >= midnight:
        return "Today"
    if ts >= midnight - 86400:
        return "Yesterday"
    return "Earlier"


def file_uri(path):
    if not path:
        return ""
    try:
        return pathlib.Path(path).absolute().as_uri()
    except ValueError:
        return ""


# ---------------------------------------------------------------------------
# database
# ---------------------------------------------------------------------------

SCHEMA = """
CREATE TABLE IF NOT EXISTS entries (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    hash         TEXT NOT NULL UNIQUE,
    mime         TEXT NOT NULL,
    kind         TEXT NOT NULL,
    preview      TEXT NOT NULL,
    filename     TEXT NOT NULL DEFAULT '',
    bytes        INTEGER NOT NULL,
    created_at   INTEGER NOT NULL,
    last_used_at INTEGER NOT NULL,
    pinned       INTEGER NOT NULL DEFAULT 0,
    blob_path    TEXT NOT NULL,
    thumb_path   TEXT NOT NULL DEFAULT '',
    meta         TEXT NOT NULL DEFAULT '{}'
);
CREATE INDEX IF NOT EXISTS idx_entries_created ON entries(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_entries_kind ON entries(kind, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_entries_pinned ON entries(pinned, created_at DESC);
CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
"""


class Store:
    def __init__(self):
        ensure_dirs()
        self.conn = sqlite3.connect(str(db_path()), timeout=10, isolation_level=None)
        self.conn.row_factory = sqlite3.Row
        self.conn.execute("PRAGMA journal_mode=WAL")
        self.conn.execute("PRAGMA synchronous=NORMAL")
        self.conn.execute("PRAGMA busy_timeout=10000")
        self.conn.executescript(SCHEMA)
        try:
            os.chmod(db_path(), 0o600)
        except OSError:
            pass
        self.fts = False
        for tokenizer in ("trigram", "unicode61"):
            try:
                self.conn.execute(
                    f"CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts USING fts5(preview, filename, meta, tokenize='{tokenizer}')"
                )
                self.fts = True
                self.fts_tokenizer = tokenizer
                break
            except sqlite3.OperationalError:
                continue
        if self.fts:
            count = self.conn.execute("SELECT count(*) FROM entries_fts").fetchone()[0]
            if count == 0:
                self.rebuild_fts()

    def rebuild_fts(self):
        if not self.fts:
            return
        self.conn.execute("DELETE FROM entries_fts")
        for row in self.conn.execute("SELECT id, preview, filename, meta FROM entries"):
            self.conn.execute(
                "INSERT INTO entries_fts(rowid, preview, filename, meta) VALUES (?,?,?,?)",
                (row["id"], row["preview"], row["filename"], row["meta"]),
            )

    def setting(self, key, default=None):
        row = self.conn.execute("SELECT value FROM settings WHERE key=?", (key,)).fetchone()
        return row["value"] if row else default

    def set_setting(self, key, value):
        self.conn.execute(
            "INSERT INTO settings(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value",
            (key, str(value)),
        )

    def entry_dict(self, row, full=False):
        thumb = row["thumb_path"] or ""
        item = {
            "id": row["id"],
            "hash": row["hash"],
            "kind": row["kind"],
            "mime": row["mime"],
            "preview": row["preview"],
            "filename": row["filename"],
            "bytes": row["bytes"],
            "createdAt": row["created_at"],
            "lastUsedAt": row["last_used_at"],
            "pinned": bool(row["pinned"]),
            "group": group_of(row["created_at"]),
            "thumbPath": file_uri(thumb) if thumb and os.path.isfile(thumb) else "",
            "domain": domain_of(row["preview"] if row["kind"] == "url" else ""),
        }
        try:
            meta = json.loads(row["meta"] or "{}")
        except ValueError:
            meta = {}
        item["app"] = meta.get("app", "")
        item["color"] = row["preview"].strip() if row["kind"] == "color" else ""
        if full:
            blob = row["blob_path"]
            if row["kind"] == "image":
                item["imagePath"] = file_uri(blob)
            elif os.path.isfile(blob):
                with open(blob, "rb") as handle:
                    raw = handle.read()
                item["content"] = raw.decode("utf-8", errors="replace")
        return item

    def counts(self):
        rows = self.conn.execute(
            """SELECT
                 count(*) AS all_count,
                 sum(CASE WHEN pinned=1 THEN 1 ELSE 0 END) AS pinned_count,
                 sum(CASE WHEN kind IN ('text','code','json','email','color','url') AND pinned=0 THEN 1 ELSE 0 END) AS text_count,
                 sum(CASE WHEN kind='image' AND pinned=0 THEN 1 ELSE 0 END) AS image_count,
                 sum(CASE WHEN kind='url' AND pinned=0 THEN 1 ELSE 0 END) AS link_count,
                 sum(CASE WHEN pinned=0 THEN 1 ELSE 0 END) AS unpinned_count
               FROM entries"""
        ).fetchone()
        return {
            "all": rows["all_count"] or 0,
            "pinned": rows["pinned_count"] or 0,
            "text": rows["text_count"] or 0,
            "images": rows["image_count"] or 0,
            "links": rows["link_count"] or 0,
            "unpinned": rows["unpinned_count"] or 0,
        }

    def list_entries(self, query="", category="all", limit=1000):
        where = []
        args = []
        if category == "pinned":
            where.append("e.pinned=1")
        elif category == "text":
            where.append("e.kind IN ('text','code','json','email','color','url')")
        elif category == "images":
            where.append("e.kind='image'")
        elif category == "links":
            where.append("e.kind='url'")
        query = (query or "").strip()
        tokens = re.findall(r"\S+", query)
        if tokens:
            if self.fts and self.fts_tokenizer == "trigram" and all(len(t) >= 3 for t in tokens):
                match = " AND ".join('"' + t.replace('"', '""') + '"' for t in tokens)
                where.append("e.id IN (SELECT rowid FROM entries_fts WHERE entries_fts MATCH ?)")
                args.append(match)
                fts_where = list(where)
                fts_args = list(args)
                rows = self._fetch(fts_where, fts_args, category, limit)
                if rows:
                    return [self.entry_dict(r) for r in rows]
                where.pop()
                args.pop()
            where.append(self._like_clause(tokens))
            for token in tokens:
                pattern = "%" + token.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%"
                args.extend([pattern] * 4)
        rows = self._fetch(where, args, category, limit)
        return [self.entry_dict(r) for r in rows]

    @staticmethod
    def _like_clause(tokens):
        parts = []
        for token in tokens:
            escaped = token.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")
            parts.append(
                "(e.preview LIKE ? ESCAPE '\\' OR e.filename LIKE ? ESCAPE '\\' OR e.meta LIKE ? ESCAPE '\\' OR e.kind LIKE ? ESCAPE '\\')"
            )
        return "(" + " AND ".join(parts) + ")"

    def _fetch(self, where, args, category, limit):
        sql = "SELECT e.* FROM entries e"
        if where:
            sql += " WHERE " + " AND ".join(where)
        order = "e.pinned DESC, e.created_at DESC, e.id DESC" if category == "all" else "e.created_at DESC, e.id DESC"
        sql += " ORDER BY " + order
        sql += " LIMIT ?"
        args = list(args) + [max(1, min(int(limit), 2000))]
        return self.conn.execute(sql, args).fetchall()

    def get(self, entry_id):
        row = self.conn.execute("SELECT * FROM entries WHERE id=?", (int(entry_id),)).fetchone()
        return self.entry_dict(row, full=True) if row else None

    def delete(self, entry_id):
        row = self.conn.execute("SELECT blob_path FROM entries WHERE id=?", (int(entry_id),)).fetchone()
        if not row:
            return False
        self.conn.execute("BEGIN")
        try:
            self.conn.execute("DELETE FROM entries WHERE id=?", (int(entry_id),))
            if self.fts:
                self.conn.execute("DELETE FROM entries_fts WHERE rowid=?", (int(entry_id),))
            self.conn.execute("COMMIT")
        except sqlite3.Error:
            self.conn.execute("ROLLBACK")
            raise
        self.cleanup_blob(row["blob_path"])
        return True

    def clear(self, include_pinned=False):
        if include_pinned:
            rows = self.conn.execute("SELECT blob_path FROM entries").fetchall()
            self.conn.execute("BEGIN")
            try:
                self.conn.execute("DELETE FROM entries")
                if self.fts:
                    self.conn.execute("DELETE FROM entries_fts")
                self.conn.execute("COMMIT")
            except sqlite3.Error:
                self.conn.execute("ROLLBACK")
                raise
        else:
            rows = self.conn.execute("SELECT blob_path FROM entries WHERE pinned=0").fetchall()
            self.conn.execute("BEGIN")
            try:
                self.conn.execute("DELETE FROM entries WHERE pinned=0")
                if self.fts:
                    self.conn.execute("DELETE FROM entries_fts WHERE rowid NOT IN (SELECT id FROM entries)")
                self.conn.execute("COMMIT")
            except sqlite3.Error:
                self.conn.execute("ROLLBACK")
                raise
        for row in rows:
            self.cleanup_blob(row["blob_path"])

    def trim(self, max_entries):
        extra = self.conn.execute("SELECT count(*) FROM entries WHERE pinned=0").fetchone()[0] - max_entries
        if extra <= 0:
            return
        rows = self.conn.execute(
            "SELECT id, blob_path FROM entries WHERE pinned=0 ORDER BY created_at ASC, id ASC LIMIT ?", (extra,)
        ).fetchall()
        for row in rows:
            self.delete(row["id"])

    def cleanup_blob(self, blob):
        if not blob:
            return
        still = self.conn.execute("SELECT count(*) FROM entries WHERE blob_path=?", (blob,)).fetchone()[0]
        if still:
            return
        try:
            os.unlink(blob)
        except OSError:
            pass
        stem = pathlib.Path(blob).stem
        for thumb in thumb_root().glob(stem + ".*"):
            try:
                thumb.unlink()
            except OSError:
                pass


# ---------------------------------------------------------------------------
# daemon
# ---------------------------------------------------------------------------

class Daemon:
    def __init__(self):
        os.umask(0o077)
        ensure_dirs()
        self.store = Store()
        self.config = load_config()
        self.selector = selectors.DefaultSelector()
        self.stop = False
        self.subscribers = []
        self.watchers = {}
        self.anchor = None
        self.last_hash = ""
        self.last_created = 0
        paused = self.store.setting("privacy_paused_until", "0")
        try:
            self.paused_until = float(paused)
        except (TypeError, ValueError):
            self.paused_until = 0
        self.lock = open(runtime_root() / "daemon.lock", "w")
        try:
            fcntl.flock(self.lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except OSError:
            raise SystemExit("verdant-clipboard: daemon already running")
        self.lock.write(str(os.getpid()))
        self.lock.flush()
        for sig in (signal.SIGTERM, signal.SIGINT):
            signal.signal(sig, self._signal)

    def _signal(self, *_):
        self.stop = True

    @property
    def wl_paste(self):
        return os.environ.get("VERDANT_WL_PASTE", "wl-paste")

    @property
    def wl_copy(self):
        return os.environ.get("VERDANT_WL_COPY", "wl-copy")

    @property
    def magick(self):
        return os.environ.get("VERDANT_MAGICK", "magick")

    def run(self):
        server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        if socket_path().exists():
            socket_path().unlink()
        server.bind(str(socket_path()))
        os.chmod(socket_path(), 0o600)
        server.listen(16)
        server.setblocking(False)
        self.selector.register(server, selectors.EVENT_READ, self._accept)
        self.restart_watchers()
        next_check = time.monotonic() + 2
        while not self.stop:
            events = self.selector.select(1.0)
            for key, _ in events:
                try:
                    key.data(key.fileobj)
                except Exception:
                    pass
            now = time.monotonic()
            if now >= next_check:
                self.check_watchers()
                next_check = now + 2
        self.shutdown()
        server.close()

    def shutdown(self):
        for proc in self.watchers.values():
            self._terminate(proc)
        self.watchers.clear()
        self._terminate(self.anchor)
        self.anchor = None
        for conn in self.subscribers:
            self._close_conn(conn)
        self.subscribers.clear()
        try:
            socket_path().unlink()
        except OSError:
            pass
        self.store.conn.close()

    @staticmethod
    def _terminate(proc):
        if proc is None:
            return
        try:
            proc.terminate()
            proc.wait(timeout=1)
        except (subprocess.SubprocessError, OSError):
            try:
                proc.kill()
            except OSError:
                pass

    def _close_conn(self, conn):
        try:
            self.selector.unregister(conn)
        except (KeyError, ValueError):
            pass
        try:
            conn.close()
        except OSError:
            pass

    def _accept(self, server):
        conn, _ = server.accept()
        creds = conn.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED, struct.calcsize("3i"))
        _, uid, _ = struct.unpack("3i", creds)
        if uid != os.getuid():
            conn.close()
            return
        conn.setblocking(False)
        self.selector.register(conn, selectors.EVENT_READ, self._client)

    def _client(self, conn):
        data = b""
        try:
            chunk = conn.recv(65536)
        except (BlockingIOError, InterruptedError):
            return
        if not chunk:
            self._close_conn(conn)
            if conn in self.subscribers:
                self.subscribers.remove(conn)
            return
        data += chunk
        while b"\n" not in data and len(data) < 131072:
            try:
                chunk = conn.recv(65536)
            except (BlockingIOError, InterruptedError):
                break
            if not chunk:
                break
            data += chunk
        line = data.split(b"\n", 1)[0][:131072]
        try:
            request = json.loads(line.decode("utf-8", "replace"))
        except ValueError:
            request = {}
        if not isinstance(request, dict):
            request = {}
        response = self.dispatch(request, conn)
        payload = json.dumps(response, ensure_ascii=False).encode("utf-8") + b"\n"
        try:
            conn.sendall(payload)
        except OSError:
            self._close_conn(conn)
            return
        if request.get("cmd") == "subscribe":
            if conn not in self.subscribers:
                self.subscribers.append(conn)
        else:
            self._close_conn(conn)

    def notify(self):
        line = b'{"type":"event","event":"changed"}\n'
        for conn in list(self.subscribers):
            try:
                conn.sendall(line)
            except OSError:
                self._close_conn(conn)
                if conn in self.subscribers:
                    self.subscribers.remove(conn)

    def dispatch(self, request, conn=None):
        cmd = request.get("cmd")
        try:
            if cmd == "ping":
                return {"ok": True, "type": "pong"}
            if cmd == "subscribe":
                return {"ok": True, "type": "subscribed"}
            if cmd == "status":
                paused = max(0, int(self.paused_until - time.time()))
                return {
                    "ok": True,
                    "type": "status",
                    "counts": self.store.counts(),
                    "pausedFor": paused,
                    "watchers": {name: bool(proc and proc.poll() is None) for name, proc in self.watchers.items()},
                    "dataRoot": str(data_root()),
                }
            if cmd == "list":
                return {
                    "ok": True,
                    "type": "list",
                    "entries": self.store.list_entries(
                        str(request.get("query", "")), str(request.get("category", "all")), int(request.get("limit", 1000))
                    ),
                    "counts": self.store.counts(),
                    "pausedFor": max(0, int(self.paused_until - time.time())),
                }
            if cmd == "get":
                entry = self.store.get(request.get("id", 0))
                return {"ok": bool(entry), "type": "entry", "entry": entry}
            if cmd == "capture":
                self.capture(request)
                return {"ok": True, "type": "captured"}
            if cmd == "restore":
                self.restore(request.get("id", 0))
                return {"ok": True, "type": "restored"}
            if cmd == "pin":
                self.store.conn.execute("UPDATE entries SET pinned=? WHERE id=?", (1 if request.get("pinned") else 0, int(request.get("id", 0))))
                self.notify()
                return {"ok": True, "type": "pinned"}
            if cmd == "delete":
                return {"ok": self.store.delete(request.get("id", 0)), "type": "deleted"}
            if cmd == "clear":
                self.store.clear(include_pinned=bool(request.get("all", False)))
                self.notify()
                return {"ok": True, "type": "cleared"}
            if cmd == "privacy":
                seconds = request.get("seconds")
                if seconds is not None:
                    self.paused_until = time.time() + max(0, int(seconds))
                elif request.get("pause"):
                    self.paused_until = time.time() + 1e9
                else:
                    self.paused_until = 0
                self.store.set_setting("privacy_paused_until", self.paused_until)
                self.notify()
                return {"ok": True, "type": "privacy", "pausedFor": max(0, int(self.paused_until - time.time()))}
            if cmd == "reload":
                self.config = load_config()
                self.restart_watchers()
                return {"ok": True, "type": "reloaded"}
        except (OSError, ValueError, sqlite3.Error) as exc:
            return {"ok": False, "error": type(exc).__name__}
        return {"ok": False, "error": "unknown command"}

    # -- watchers ----------------------------------------------------------

    def start_watcher(self, name, extra_args):
        script = os.path.abspath(__file__)
        command = [self.wl_paste] + extra_args + ["--watch", sys.executable, script, "capture", "--source", name]
        try:
            self.watchers[name] = subprocess.Popen(
                command, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
            )
        except OSError:
            self.watchers[name] = None

    def restart_watchers(self):
        for proc in self.watchers.values():
            self._terminate(proc)
        self.watchers.clear()
        self.start_watcher("default", [])
        if self.config.get("captureImages"):
            self.start_watcher("image", ["--type", "image"])

    def check_watchers(self):
        for name, proc in list(self.watchers.items()):
            if proc is None or proc.poll() is not None:
                if name == "image" and not self.config.get("captureImages"):
                    continue
                extra = ["--type", "image"] if name == "image" else []
                self.start_watcher(name, extra)

    # -- capture -----------------------------------------------------------

    def capture(self, request):
        if self.paused_until > time.time():
            return
        if request.get("state", "data") != "data":
            return
        path = str(request.get("path", ""))
        if not path or not os.path.isfile(path):
            return
        with open(path, "rb") as handle:
            data = handle.read()
        sha = hashlib.sha256(data).hexdigest()
        mime, kind, text = sniff(data, str(request.get("source", "default")))
        if mime == "text/html" and text and "<img" in text.lower():
            return
        if kind == "image" and len(data) > self.config["maxImageBytes"]:
            return
        if kind == "image" and not self.config.get("captureImages"):
            return
        if kind != "image" and len(data) > self.config["maxTextBytes"] and len(data) > self.config["maxOtherBytes"]:
            return
        app = str(request.get("app", ""))[:120]
        for ignored in self.config["ignoreApps"]:
            if ignored and ignored.lower() in app.lower():
                return
        for pattern in self.config["ignorePatterns"]:
            if text and pattern:
                try:
                    if re.search(pattern, text):
                        return
                except re.error:
                    continue
        now = int(time.time())
        if sha == self.last_hash and now - self.last_created < 2:
            return
        existing = self.store.conn.execute("SELECT id, pinned FROM entries WHERE hash=?", (sha,)).fetchone()
        if existing:
            self.store.conn.execute(
                "UPDATE entries SET created_at=?, last_used_at=? WHERE id=?", (now, now, existing["id"])
            )
            self.last_hash, self.last_created = sha, now
            self.notify()
            return
        blob_dir = blob_root() / sha[:2] / sha[2:4]
        blob_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
        blob = blob_dir / (sha + ".bin")
        tmp = blob.with_suffix(".tmp-" + uuid.uuid4().hex)
        with open(tmp, "wb") as handle:
            handle.write(data)
        os.chmod(tmp, 0o600)
        os.replace(tmp, blob)
        thumb = ""
        if kind == "image":
            thumb = self.make_thumb(blob, sha)
        filename = ""
        if kind == "file" and text:
            filename = pathlib.Path(text.strip().replace("file://", "")).name[:200]
        meta = json.dumps({"app": app, "mime": mime, "source": request.get("source", "default")}, ensure_ascii=False)
        self.store.conn.execute("BEGIN")
        try:
            cursor = self.store.conn.execute(
                """INSERT INTO entries(hash,mime,kind,preview,filename,bytes,created_at,last_used_at,pinned,blob_path,thumb_path,meta)
                   VALUES(?,?,?,?,?,?,?,?,0,?,?,?)""",
                (
                    sha,
                    mime,
                    kind,
                    preview_for(text, self.config["previewChars"]),
                    filename,
                    len(data),
                    now,
                    now,
                    str(blob),
                    thumb,
                    meta,
                ),
            )
            entry_id = cursor.lastrowid
            if self.store.fts:
                self.store.conn.execute(
                    "INSERT INTO entries_fts(rowid, preview, filename, meta) VALUES(?,?,?,?)",
                    (entry_id, preview_for(text, self.config["previewChars"]), filename, meta),
                )
            self.store.conn.execute("COMMIT")
        except sqlite3.Error:
            self.store.conn.execute("ROLLBACK")
            raise
        self.last_hash, self.last_created = sha, now
        self.store.trim(self.config["maxEntries"])
        self.notify()

    def make_thumb(self, blob, sha):
        thumb = thumb_root() / (sha + ".png")
        if thumb.exists():
            return str(thumb)
        tmp = thumb.with_suffix(".tmp-" + uuid.uuid4().hex)
        command = [
            self.magick,
            str(blob) + "[0]",
            "-auto-orient",
            "-thumbnail",
            str(self.config["thumbnailPx"]) + "x" + str(self.config["thumbnailPx"]) + ">",
            "png32:" + str(tmp),
        ]
        try:
            result = subprocess.run(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=8)
            if result.returncode == 0 and tmp.is_file():
                os.chmod(tmp, 0o600)
                os.replace(tmp, thumb)
                return str(thumb)
        except (OSError, subprocess.SubprocessError):
            pass
        try:
            tmp.unlink()
        except OSError:
            pass
        return ""

    # -- restore -----------------------------------------------------------

    def restore(self, entry_id):
        row = self.store.conn.execute("SELECT * FROM entries WHERE id=?", (int(entry_id),)).fetchone()
        if not row or not os.path.isfile(row["blob_path"]):
            raise ValueError("entry not found")
        with open(row["blob_path"], "rb") as handle:
            data = handle.read()
        now = int(time.time())
        self.store.conn.execute("UPDATE entries SET last_used_at=? WHERE id=?", (now, row["id"]))
        self.last_hash, self.last_created = row["hash"], now
        self._terminate(self.anchor)
        self.anchor = None
        mime = row["mime"] or "text/plain;charset=utf-8"
        try:
            subprocess.run(
                [self.wl_copy, "-t", mime], input=data, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5
            )
            if self.config.get("persistRestore"):
                self.anchor = subprocess.Popen(
                    [self.wl_copy, "-f", "-t", mime],
                    stdin=subprocess.PIPE,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                if self.anchor.stdin:
                    self.anchor.stdin.write(data)
                    self.anchor.stdin.close()
        except (OSError, subprocess.SubprocessError):
            pass
        self.notify()


# ---------------------------------------------------------------------------
# capture helper / ctl
# ---------------------------------------------------------------------------

def active_app():
    try:
        result = subprocess.run(
            ["hyprctl", "-j", "activewindow"], capture_output=True, text=True, timeout=1
        )
        if result.returncode == 0:
            info = json.loads(result.stdout)
            return str(info.get("class") or info.get("initialClass") or "")[:120]
    except (OSError, ValueError, subprocess.SubprocessError):
        pass
    return ""


def send_request(request, timeout=5):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(timeout)
    try:
        sock.connect(str(socket_path()))
        sock.sendall((json.dumps(request, ensure_ascii=False) + "\n").encode("utf-8"))
        data = b""
        while b"\n" not in data:
            chunk = sock.recv(65536)
            if not chunk:
                break
            data += chunk
        return json.loads(data.split(b"\n", 1)[0].decode("utf-8", "replace"))
    finally:
        sock.close()


def cmd_capture(argv):
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--source", default="default")
    args = parser.parse_args(argv)
    state = os.environ.get("CLIPBOARD_STATE", "data")
    if state != "data":
        return 0
    cfg = load_config()
    limit = max(cfg["maxImageBytes"], cfg["maxTextBytes"], cfg["maxOtherBytes"])
    data = sys.stdin.buffer.read(limit + 1)
    if len(data) > limit:
        return 0
    ensure_dirs()
    incoming = runtime_root() / "incoming" / (uuid.uuid4().hex + ".bin")
    fd = os.open(str(incoming), os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "wb") as handle:
        handle.write(data)
    request = {
        "cmd": "capture",
        "path": str(incoming),
        "state": state,
        "source": args.source,
        "app": active_app(),
    }
    for _ in range(10):
        try:
            send_request(request, timeout=3)
            break
        except (OSError, ValueError):
            time.sleep(0.2)
    try:
        incoming.unlink()
    except OSError:
        pass
    return 0


def cmd_subscribe():
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        sock.connect(str(socket_path()))
        sock.sendall(b'{"cmd":"subscribe"}\n')
        buffer = b""
        while True:
            chunk = sock.recv(65536)
            if not chunk:
                return 1
            buffer += chunk
            while b"\n" in buffer:
                line, buffer = buffer.split(b"\n", 1)
                if line:
                    sys.stdout.write(line.decode("utf-8", "replace") + "\n")
                    sys.stdout.flush()
    finally:
        sock.close()


def cmd_ctl(argv):
    if not argv:
        print(json.dumps({"ok": False, "error": "missing command"}))
        return 2
    cmd = argv[0]
    if cmd == "subscribe":
        try:
            return cmd_subscribe()
        except OSError:
            return 1
    request = {"cmd": cmd}
    if cmd == "list":
        request["query"] = argv[1] if len(argv) > 1 else ""
        request["category"] = argv[2] if len(argv) > 2 else "all"
    elif cmd == "get":
        request["id"] = int(argv[1]) if len(argv) > 1 else 0
    elif cmd in ("restore", "delete", "pin"):
        request["id"] = int(argv[1]) if len(argv) > 1 else 0
        if cmd == "pin":
            request["pinned"] = len(argv) > 2 and argv[2].lower() not in ("0", "false", "off", "unpin")
    elif cmd == "clear":
        request["all"] = len(argv) > 1 and argv[1] in ("all", "--all")
    elif cmd == "privacy":
        if argv[1:] and argv[1] == "pause":
            request["pause"] = True
            if len(argv) > 2:
                request["seconds"] = int(argv[2])
        else:
            request["pause"] = False
    try:
        response = send_request(request)
    except (OSError, ValueError) as exc:
        response = {"ok": False, "error": type(exc).__name__}
    print(json.dumps(response, ensure_ascii=False))
    return 0 if response.get("ok") else 1


def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("mode", nargs="?", default="daemon")
    args, rest = parser.parse_known_args()
    if args.mode == "capture":
        return cmd_capture(rest)
    if args.mode == "ctl":
        return cmd_ctl(rest)
    daemon = Daemon()
    return daemon.run() or 0


if __name__ == "__main__":
    sys.exit(main())
