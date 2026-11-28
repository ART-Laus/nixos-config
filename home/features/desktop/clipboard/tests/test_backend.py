#!/usr/bin/env python3
"""Unit tests for the Verdant Clipboard backend (stdlib only).

Run with:
    python3 -m unittest discover -s home/features/desktop/clipboard/tests -v
"""

import importlib.util
import os
import stat
import sys
import tempfile
import time
import unittest
from pathlib import Path
from unittest import mock

MODULE_PATH = Path(__file__).resolve().parents[1] / "backend" / "verdant_clipboard.py"
spec = importlib.util.spec_from_file_location("verdant_clipboard", MODULE_PATH)
vc = importlib.util.module_from_spec(spec)
sys.modules["verdant_clipboard"] = vc
spec.loader.exec_module(vc)


class BackendTestCase(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="verdant-test-")
        self.root = Path(self.tmp.name)
        self.data = self.root / "data"
        self.config = self.root / "config" / "verdant-clipboard"
        self.runtime = self.root / "runtime"
        for directory in (self.data, self.config, self.runtime):
            directory.mkdir(parents=True, exist_ok=True)
        self.fake_copy = self.root / "wl-copy"
        self.fake_copy.write_text(
            "#!/bin/sh\ncat > \"$VERDANT_TEST_COPY_OUT\"\n", encoding="utf-8"
        )
        self.fake_copy.chmod(self.fake_copy.stat().st_mode | stat.S_IEXEC)
        self.copy_out = self.root / "copied.bin"
        self.env_patch = mock.patch.dict(
            os.environ,
            {
                "XDG_DATA_HOME": str(self.data),
                "XDG_CONFIG_HOME": str(self.root / "config"),
                "XDG_RUNTIME_DIR": str(self.runtime),
                "VERDANT_WL_COPY": str(self.fake_copy),
                "VERDANT_WL_PASTE": "/bin/true",
                "VERDANT_MAGICK": "/bin/false",
                "VERDANT_TEST_COPY_OUT": str(self.copy_out),
            },
        )
        self.env_patch.start()
        self.daemon = None

    def tearDown(self):
        if self.daemon is not None:
            self.daemon._terminate(self.daemon.anchor)
            try:
                self.daemon.store.conn.close()
            except Exception:
                pass
            try:
                self.daemon.lock.close()
            except Exception:
                pass
        self.env_patch.stop()
        self.tmp.cleanup()

    def new_daemon(self, config=None):
        if config is not None:
            (self.config / "config.json").write_text(vc.json.dumps(config), encoding="utf-8")
        self.daemon = vc.Daemon()
        return self.daemon

    def capture(self, data, source="default", state="data", app=""):
        incoming = self.runtime / ("incoming-" + vc.uuid.uuid4().hex + ".bin")
        incoming.write_bytes(data)
        self.daemon.capture(
            {"path": str(incoming), "state": state, "source": source, "app": app}
        )
        incoming.unlink(missing_ok=True)

    def entries(self, query="", category="all"):
        return self.daemon.store.list_entries(query, category)


class TestClassification(BackendTestCase):
    def test_sniff_types(self):
        cases = [
            (b"plain text", "text"),
            (b"https://example.org/path?x=1", "url"),
            (b"user@example.org", "email"),
            (b"#66FF99", "color"),
            (b'{"a": [1, 2, 3]}', "json"),
            (b"def hello():\n    return 1\n", "code"),
            (b"\x89PNG\r\n\x1a\nrest", "image"),
            (b"\xff\xd8\xff\xe0rest", "image"),
            (b"<html><body>hi</body></html>", "html"),
            (b"\x00\x01\x02not text", "other"),
        ]
        for data, expected in cases:
            with self.subTest(data=data[:20]):
                _, kind, _ = vc.sniff(data)
                self.assertEqual(kind, expected)

    def test_preview_preserves_unicode_and_collapses_lines(self):
        text = "  first\tline  \nвторая строка 🚀\n\nthird   "
        _, kind, decoded = vc.sniff(text.encode())
        self.assertEqual(kind, "text")
        self.assertEqual(decoded, text)
        preview = vc.preview_for(decoded, 500)
        self.assertIn("вторая строка 🚀", preview)
        self.assertNotIn("\n", preview)

    def test_group_of(self):
        now = time.time()
        self.assertEqual(vc.group_of(now), "Today")
        self.assertEqual(vc.group_of(now - 86400), "Yesterday")
        self.assertEqual(vc.group_of(now - 86400 * 3), "Earlier")


class TestStorage(BackendTestCase):
    def test_capture_dedup_and_pinned_state(self):
        daemon = self.new_daemon()
        original = "hello\nverdant 🚀".encode()
        self.capture(original)
        first = self.entries()[0]
        self.assertEqual(first["kind"], "text")
        self.assertEqual(first["pinned"], False)

        daemon.store.conn.execute("UPDATE entries SET pinned=1 WHERE id=?", (first["id"],))
        daemon.last_hash = ""
        time.sleep(1.1)
        self.capture(original)
        rows = self.entries()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["id"], first["id"])
        self.assertTrue(rows[0]["pinned"])
        self.assertGreater(rows[0]["createdAt"], first["createdAt"])

    def test_binary_blob_preserved_and_deleted(self):
        daemon = self.new_daemon()
        payload = b"\x00\xff\x10binary\x00data\n"
        self.capture(payload)
        row = daemon.store.conn.execute("SELECT blob_path FROM entries").fetchone()
        self.assertEqual(Path(row["blob_path"]).read_bytes(), payload)
        entry = self.entries()[0]
        self.assertTrue(daemon.store.delete(entry["id"]))
        self.assertFalse(Path(row["blob_path"]).exists())

    def test_search_and_categories(self):
        self.new_daemon()
        self.capture(b"https://example.org/docs")
        self.capture(b"meeting notes about alpha")
        self.capture(b"def compute():\n    return 42\n")
        self.capture(b"\x89PNG\r\n\x1a\nfake")

        self.assertEqual(len(self.entries("alpha")), 1)
        self.assertEqual(self.entries("alpha")[0]["preview"], "meeting notes about alpha")
        self.assertEqual(len(self.entries("example.org", "links")), 1)
        self.assertEqual(len(self.entries("", "text")), 3)
        self.assertEqual(len(self.entries("", "images")), 1)
        self.assertEqual(len(self.entries("", "pinned")), 0)

    def test_pin_survives_clear_unpinned(self):
        daemon = self.new_daemon()
        self.capture(b"keep me")
        self.capture(b"remove me")
        entry = self.entries("keep me")[0]
        daemon.store.conn.execute("UPDATE entries SET pinned=1 WHERE id=?", (entry["id"],))
        daemon.store.clear(include_pinned=False)
        self.assertEqual(len(self.entries()), 1)
        self.assertEqual(self.entries()[0]["preview"], "keep me")
        daemon.store.clear(include_pinned=True)
        self.assertEqual(len(self.entries()), 0)

    def test_limit_excludes_pinned(self):
        daemon = self.new_daemon({"maxEntries": 3})
        for index in range(5):
            self.capture(("entry-%d" % index).encode())
            time.sleep(0.05)
        entry = self.entries("entry-4")[0]
        daemon.store.conn.execute("UPDATE entries SET pinned=1 WHERE id=?", (entry["id"],))
        daemon.store.trim(3)
        rows = self.entries()
        self.assertEqual(len(rows), 3)
        self.assertTrue(any(row["pinned"] for row in rows))

    def test_sensitive_and_privacy_pause(self):
        daemon = self.new_daemon()
        self.capture(b"password-manager-secret", state="sensitive")
        self.assertEqual(len(self.entries()), 0)
        daemon.paused_until = time.time() + 60
        self.capture(b"private text")
        self.assertEqual(len(self.entries()), 0)
        daemon.paused_until = 0
        self.capture(b"public text")
        self.assertEqual(len(self.entries()), 1)

    def test_ignore_apps_and_patterns(self):
        daemon = self.new_daemon(
            {"ignoreApps": ["secretapp"], "ignorePatterns": ["otp-\\d+"]}
        )
        self.capture(b"from secret app", app="SecretApp-window")
        self.capture(b"your otp-123456 code")
        self.capture(b"normal text")
        self.assertEqual([row["preview"] for row in self.entries()], ["normal text"])

    def test_restore_fake_copy(self):
        daemon = self.new_daemon()
        payload = b"restored bytes\nwith newline\tand unicode \xf0\x9f\x9a\x80"
        self.capture(payload)
        entry = self.entries()[0]
        daemon.restore(entry["id"])
        self.assertEqual(self.copy_out.read_bytes(), payload)

    def test_dispatch_commands(self):
        daemon = self.new_daemon()
        self.assertEqual(daemon.dispatch({"cmd": "ping"})["type"], "pong")
        self.capture(b"dispatch me")
        entry = self.entries()[0]
        listed = daemon.dispatch({"cmd": "list", "query": "dispatch"})
        self.assertEqual(len(listed["entries"]), 1)
        got = daemon.dispatch({"cmd": "get", "id": entry["id"]})
        self.assertEqual(got["entry"]["content"], "dispatch me")
        self.assertTrue(daemon.dispatch({"cmd": "pin", "id": entry["id"], "pinned": True})["ok"])
        self.assertTrue(self.entries()[0]["pinned"])
        self.assertTrue(daemon.dispatch({"cmd": "privacy", "seconds": 30})["ok"])
        self.assertGreater(daemon.paused_until, time.time())
        daemon.dispatch({"cmd": "privacy", "pause": False})
        self.assertEqual(daemon.paused_until, 0)
        self.assertTrue(daemon.dispatch({"cmd": "clear", "all": True})["ok"])
        self.assertEqual(len(self.entries()), 0)


class TestCli(BackendTestCase):
    def test_ctl_clear_arguments(self):
        captured = []
        with mock.patch.object(vc, "send_request", side_effect=lambda req: captured.append(req) or {"ok": True}), \
             mock.patch("sys.stdout"):
            vc.cmd_ctl(["clear"])
            vc.cmd_ctl(["clear", "all"])
            vc.cmd_ctl(["privacy", "pause", "30"])
        self.assertEqual(captured[0]["cmd"], "clear")
        self.assertFalse(captured[0]["all"])
        self.assertTrue(captured[1]["all"])
        self.assertTrue(captured[2]["pause"])
        self.assertEqual(captured[2]["seconds"], 30)


class TestConfig(BackendTestCase):
    def test_defaults_and_overrides(self):
        defaults = vc.load_config()
        self.assertEqual(defaults["maxEntries"], 1000)
        self.assertTrue(defaults["captureImages"])
        (self.config / "config.json").write_text(
            vc.json.dumps({"maxEntries": 25, "captureImages": False, "ignoreApps": ["pw"]}),
            encoding="utf-8",
        )
        cfg = vc.load_config()
        self.assertEqual(cfg["maxEntries"], 25)
        self.assertFalse(cfg["captureImages"])
        self.assertEqual(cfg["ignoreApps"], ["pw"])


if __name__ == "__main__":
    unittest.main()
