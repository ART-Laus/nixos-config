import argparse
import json
import os
import re
import shutil
import sys
import time

DEFAULT_METADATA = {
    "archive": {
        "name": "Archive",
        "description": "Create an archive from selected files",
        "category": "Files & Storage",
        "icon": "󰀼",
        "tags": ["files", "archive"],
        "arguments": [
            {"name": "output", "label": "Output archive", "type": "text", "required": True, "placeholder": "/path/to/archive.zip"},
            {"name": "files", "label": "Files", "type": "files", "required": True, "placeholder": "file1 file2"}
        ]
    },
    "extract": {
        "name": "Extract",
        "description": "Extract archives into their own directories",
        "category": "Files & Storage",
        "icon": "󰀼",
        "tags": ["files", "archive"],
        "arguments": [
            {"name": "archives", "label": "Archives", "type": "files", "required": True, "placeholder": "archive.zip archive.tar.gz"}
        ]
    },
    "fileinfo": {
        "name": "File Info",
        "description": "Show type, size, checksum, timestamp, and metadata for files",
        "category": "Files & Storage",
        "icon": "󰋼",
        "tags": ["files", "inspect"],
        "arguments": [
            {"name": "files", "label": "Files", "type": "files", "required": True, "placeholder": "file1 file2"}
        ]
    },
    "hashfile": {
        "name": "Hash File",
        "description": "Print the SHA-256 checksum of files",
        "category": "Files & Storage",
        "icon": "󰌒",
        "tags": ["files", "hash"],
        "arguments": [
            {"name": "files", "label": "Files", "type": "files", "required": True, "placeholder": "file1 file2"}
        ]
    },
    "find-duplicates": {
        "name": "Find Duplicates",
        "description": "Scan a directory recursively for duplicate files",
        "category": "Files & Storage",
        "icon": "󰀼",
        "tags": ["files", "cleanup"],
        "arguments": [
            {"name": "directory", "label": "Directory", "type": "directory", "required": True, "default": "/home/artlaus/Downloads"}
        ]
    },
    "tidy-downloads": {
        "name": "Tidy Downloads",
        "description": "Analyze Downloads by file type without moving anything",
        "category": "Files & Storage",
        "icon": "󰋼",
        "tags": ["downloads", "dry-run"],
        "arguments": [
            {"name": "directory", "label": "Directory", "type": "directory", "required": False, "default": "/home/artlaus/Downloads"}
        ]
    },
    "batch-rename": {
        "name": "Batch Rename",
        "description": "Rename multiple files with a pattern and replacement",
        "category": "Files & Storage",
        "icon": "󰑕",
        "tags": ["files", "rename"],
        "confirm": True,
        "arguments": [
            {"name": "pattern", "label": "Pattern", "type": "text", "required": True},
            {"name": "replacement", "label": "Replacement", "type": "text", "required": False, "default": ""},
            {"name": "files", "label": "Files", "type": "files", "required": True, "placeholder": "file1 file2"}
        ]
    },
    "share": {
        "name": "Share Directory",
        "description": "Serve a directory over HTTP on localhost",
        "category": "Network",
        "icon": "󰈐",
        "tags": ["network", "server"],
        "execution": {"mode": "long", "allowMultipleInstances": False},
        "arguments": [
            {"name": "port", "label": "Port", "type": "number", "required": False, "default": 8080},
            {"name": "directory", "label": "Directory", "type": "directory", "required": False, "default": "/home/artlaus"}
        ]
    },
    "doctor": {
        "name": "System Doctor",
        "description": "Collect a compact health report for Nix, services, disk, memory, and tools",
        "category": "System",
        "icon": "󰀫",
        "tags": ["system", "diagnostics"],
        "execution": {"mode": "normal", "timeout": 60}
    },
    "nixcheck": {
        "name": "Nix Check",
        "description": "Run common Nix maintenance commands",
        "category": "Maintenance",
        "icon": "󰀱",
        "tags": ["nix", "maintenance"],
        "arguments": [
            {"name": "command", "label": "Command", "type": "select", "required": True, "default": "flake", "options": ["flake", "build", "eval", "format", "generations", "gc", "search"]},
            {"name": "extra", "label": "Extra arguments", "type": "text", "required": False}
        ]
    },
    "wallpaper": {
        "name": "Random Wallpaper",
        "description": "Pick a random wallpaper and apply it to all monitors",
        "category": "Desktop & Appearance",
        "icon": "󰸁",
        "tags": ["desktop", "wallpaper"]
    },
    "show-desktop": {
        "name": "Show Desktop",
        "description": "Toggle all windows between the current workspaces and a special workspace",
        "category": "Desktop & Appearance",
        "icon": "󰽯",
        "tags": ["desktop", "hyprland"]
    },
    "rofi-scripts": {
        "name": "Rofi Media Menu",
        "description": "Open the Rofi menu for image, video, and audio scripts",
        "category": "Media",
        "icon": "󰎐",
        "tags": ["rofi", "media"]
    },
    "rofi-image": {
        "name": "Rofi Image Tools",
        "description": "Convert, resize, and crop images through Rofi prompts",
        "category": "Media",
        "icon": "󰈟",
        "tags": ["rofi", "image"]
    },
    "rofi-video": {
        "name": "Rofi Video Tools",
        "description": "Convert, resize, and crop videos through Rofi prompts",
        "category": "Media",
        "icon": "󰈣",
        "tags": ["rofi", "video"]
    },
    "rofi-audio": {
        "name": "Rofi Audio Tools",
        "description": "Convert, change bitrate, and trim audio through Rofi prompts",
        "category": "Media",
        "icon": "󰈧",
        "tags": ["rofi", "audio"]
    },
    "make-qr": {
        "name": "Make QR",
        "description": "Generate a QR code PNG from text or a URL",
        "category": "Utilities",
        "icon": "󰀀",
        "tags": ["qr", "image"],
        "arguments": [
            {"name": "text", "label": "Text or URL", "type": "text", "required": True},
            {"name": "output", "label": "Output PNG", "type": "text", "required": False, "default": "qr.png"}
        ]
    },
    "clip-ocr": {
        "name": "Clipboard OCR",
        "description": "Run OCR on an image currently stored in the clipboard",
        "category": "Utilities",
        "icon": "󰈤",
        "tags": ["clipboard", "ocr"]
    },
    "img-resize": {
        "name": "Resize Image",
        "description": "Resize an image to a geometry or percentage",
        "category": "Media",
        "icon": "󰈟",
        "tags": ["image", "resize"],
        "arguments": [
            {"name": "file", "label": "Image", "type": "file", "required": True},
            {"name": "geometry", "label": "Geometry", "type": "text", "required": True, "default": "1920x1080", "placeholder": "1920x1080, 50%, 1920x1080>"}
        ]
    },
    "img-compress": {
        "name": "Compress Images",
        "description": "Optimize images in place where supported",
        "category": "Media",
        "icon": "󰈟",
        "tags": ["image", "optimize"],
        "confirm": True,
        "arguments": [
            {"name": "files", "label": "Images", "type": "files", "required": True, "placeholder": "image1.png image2.jpg"}
        ]
    },
    "vid2audio": {
        "name": "Video to Audio",
        "description": "Extract audio from a video file",
        "category": "Media",
        "icon": "󰈣",
        "tags": ["video", "audio", "ffmpeg"],
        "arguments": [
            {"name": "video", "label": "Video", "type": "file", "required": True},
            {"name": "output", "label": "Output MP3", "type": "text", "required": False}
        ]
    },
    "vid2gif": {
        "name": "Video to GIF",
        "description": "Create a short GIF preview from a video file",
        "category": "Media",
        "icon": "󰈣",
        "tags": ["video", "gif", "ffmpeg"],
        "arguments": [
            {"name": "video", "label": "Video", "type": "file", "required": True},
            {"name": "output", "label": "Output GIF", "type": "text", "required": False}
        ]
    },
    "pdf2text": {
        "name": "PDF to Text",
        "description": "Extract text from a PDF file",
        "category": "Utilities",
        "icon": "󰈙",
        "tags": ["pdf", "text"],
        "arguments": [
            {"name": "pdf", "label": "PDF", "type": "file", "required": True},
            {"name": "output", "label": "Output TXT", "type": "text", "required": False}
        ]
    },
    "new-note": {
        "name": "New Note",
        "description": "Create a note in the ideas directory and open it in Neovim",
        "category": "Utilities",
        "icon": "󰈏",
        "tags": ["notes", "editor"],
        "arguments": [
            {"name": "title", "label": "Note title", "type": "text", "required": True}
        ]
    },
    "docker": {
        "name": "Docker Compat",
        "description": "Podman compatibility command named docker",
        "category": "System",
        "icon": "󰀱",
        "tags": ["podman", "compat"],
        "hidden": True
    },
    "docker-compose": {
        "name": "Docker Compose Compat",
        "description": "Podman Compose compatibility command named docker-compose",
        "category": "System",
        "icon": "󰀱",
        "tags": ["podman", "compat"],
        "hidden": True
    },
    "carpheus-api": {
        "name": "Carpheus API",
        "description": "Internal Navidrome API helper for the music panel",
        "category": "Development",
        "icon": "󰘲",
        "tags": ["internal", "music"],
        "hidden": True
    },
    "carpheus-mpv-ipc": {
        "name": "Carpheus MPV IPC",
        "description": "Internal mpv IPC helper for the music panel",
        "category": "Development",
        "icon": "󰘲",
        "tags": ["internal", "music"],
        "hidden": True,
        "execution": {"mode": "long", "allowMultipleInstances": False}
    },
    "now": {
        "name": "Last.fm Now Playing",
        "description": "Legacy Last.fm now-playing helper with placeholder credentials",
        "category": "Media",
        "icon": "󰈧",
        "tags": ["legacy", "music"],
        "hidden": True
    }
}


def load_json(path, fallback):
    try:
        if not path or not os.path.exists(path):
            return fallback
        with open(path, "r", encoding="utf-8") as handle:
            value = json.load(handle)
        return value if isinstance(value, dict) else fallback
    except Exception:
        return fallback


def normalize_key(value):
    base = os.path.basename(str(value or "")).strip().lower()
    base = re.sub(r"\.sh$", "", base)
    base = re.sub(r"\.(py|bash|zsh|fish)$", "", base)
    base = re.sub(r"[^a-z0-9]+", "-", base).strip("-")
    return base or "unnamed"


def pretty_name(value):
    base = os.path.basename(str(value or ""))
    base = re.sub(r"\.(sh|py|bash|zsh|fish)$", "", base)
    base = re.sub(r"[-_]+", " ", base)
    return base.title() or "Untitled"


def read_shebang(path):
    try:
        with open(path, "rb") as handle:
            data = handle.read(256)
        first = data.split(b"\n", 1)[0].decode("utf-8", errors="replace").strip()
        return first if first.startswith("#!") else ""
    except Exception:
        return ""


def interpreter_of(shebang):
    low = shebang.lower()
    if "python" in low:
        return "python"
    if "bash" in low:
        return "bash"
    if "/sh" in low or "sh -" in low:
        return "sh"
    if "zsh" in low:
        return "zsh"
    if "fish" in low:
        return "fish"
    if low:
        return "other"
    return ""


def scalar(meta, key, fallback=None):
    value = meta.get(key, fallback)
    return fallback if value is None else value


def execution_value(meta, key, fallback):
    execution = meta.get("execution")
    if isinstance(execution, dict) and key in execution:
        return execution[key]
    return meta.get(key, fallback)


def meta_for(key, command_config, custom_metadata):
    merged = {}
    merged.update(DEFAULT_METADATA.get(key, {}))
    custom = custom_metadata.get(key)
    if isinstance(custom, dict):
        merged.update(custom)
    if isinstance(command_config, dict):
        for key_name in ("displayName", "description", "category", "icon", "hidden", "favorite"):
            if key_name in command_config:
                merged[key_name] = command_config[key_name]
    return merged


def make_item(key, path, command, source, source_path, executable, shebang, mtime, kind, config, custom_metadata, state):
    meta = meta_for(key, config, custom_metadata)
    tags = meta.get("tags", [])
    if not isinstance(tags, list):
        tags = [str(tags)] if tags else []
    arguments = meta.get("arguments", [])
    if not isinstance(arguments, list):
        arguments = []
    favorites = state.get("favorites", [])
    usage = state.get("usage", {})
    used = usage.get(key, {}) if isinstance(usage, dict) else {}
    return {
        "id": key,
        "key": key,
        "name": str(scalar(meta, "name", pretty_name(path or command or key))),
        "description": str(scalar(meta, "description", "")),
        "category": str(scalar(meta, "category", "Uncategorized")),
        "icon": str(scalar(meta, "icon", "󰘲")),
        "tags": [str(tag) for tag in tags],
        "favorite": key in favorites or bool(scalar(meta, "favorite", False)),
        "hidden": bool(scalar(meta, "hidden", False)),
        "confirm": bool(scalar(meta, "confirm", False)),
        "executionMode": str(execution_value(meta, "mode", "normal")),
        "timeout": int(execution_value(meta, "timeout", 0) or 0),
        "allowMultipleInstances": bool(execution_value(meta, "allowMultipleInstances", False)),
        "workingDirectory": str(scalar(meta, "workingDirectory", "")),
        "arguments": arguments,
        "path": os.path.abspath(path) if path else "",
        "sourcePath": os.path.abspath(source_path) if source_path else "",
        "command": command,
        "source": str(source or "Scripts"),
        "filename": os.path.basename(path or command or key),
        "extension": os.path.splitext(path or command or key)[1],
        "executable": bool(executable),
        "launchable": bool(executable and (path or command)),
        "interpreter": interpreter_of(shebang),
        "shebang": shebang,
        "mtime": int(mtime or 0),
        "kind": kind,
        "available": True,
        "launches": int(used.get("launches", 0) or 0) if isinstance(used, dict) else 0,
        "lastUsed": int(used.get("lastUsed", 0) or 0) if isinstance(used, dict) else 0,
        "issue": ""
    }


def should_skip(name):
    if name.startswith("."):
        return True
    if name in {"node_modules", "venv", "__pycache__", ".git"}:
        return True
    if name.endswith((".nix", ".json", ".md", ".txt", ".bak", ".db", ".log")):
        return True
    return False


def scan_root(root, depth, config, custom_metadata, state, items):
    path = os.path.abspath(os.path.expanduser(str(root.get("path", ""))))
    if not path or not os.path.isdir(path):
        return
    if path.startswith(("/proc", "/sys", "/dev")):
        return
    max_depth = int(root.get("maxDepth", 1) if root.get("recursive", True) else 0)
    label = str(root.get("label", "Scripts"))
    try:
        entries = list(os.scandir(path))
    except Exception:
        return
    for entry in entries:
        if should_skip(entry.name):
            continue
        full = os.path.join(path, entry.name)
        if any(full == excluded or full.startswith(excluded.rstrip("/") + "/") for excluded in config.get("excluded", [])):
            continue
        try:
            if entry.is_dir(follow_symlinks=False):
                if depth < max_depth:
                    child = dict(root)
                    child["path"] = full
                    scan_root(child, depth + 1, config, custom_metadata, state, items)
                continue
            if not entry.is_file(follow_symlinks=False):
                continue
            stat_result = entry.stat(follow_symlinks=False)
            shebang = read_shebang(full)
            if not shebang:
                continue
            executable = bool(stat_result.st_mode & 0o111)
            key = normalize_key(entry.name)
            item = make_item(key, full, full, label, "", executable, shebang, stat_result.st_mtime, "script", None, custom_metadata, state)
            item["prefer"] = 1 if executable else 0
            if not executable:
                item["issue"] = "Not executable"
            items.setdefault(key, []).append(item)
        except Exception:
            continue


def scan_commands(config, custom_metadata, state, items):
    for command_config in config.get("commands", []):
        if not isinstance(command_config, dict):
            continue
        name = str(command_config.get("command", command_config.get("name", "")))
        if not name:
            continue
        resolved = shutil.which(name)
        if not resolved:
            continue
        try:
            stat_result = os.lstat(resolved)
        except Exception:
            continue
        key = normalize_key(name)
        item = make_item(key, resolved, name, str(command_config.get("label", "Nix commands")), "", True, "", stat_result.st_mtime, "command-wrapper", command_config, custom_metadata, state)
        item["prefer"] = 2
        item["path"] = resolved
        item["sourcePath"] = ""
        items.setdefault(key, []).append(item)


def merge_items(items):
    result = []
    for key, candidates in items.items():
        candidates.sort(key=lambda item: item.get("prefer", 0), reverse=True)
        chosen = dict(candidates[0])
        for candidate in candidates[1:]:
            if candidate.get("kind") == "script" and not chosen.get("sourcePath"):
                chosen["sourcePath"] = candidate.get("path", "")
            if candidate.get("executable") and not chosen.get("executable"):
                chosen["executable"] = True
                chosen["launchable"] = True
                chosen["issue"] = ""
        chosen.pop("prefer", None)
        result.append(chosen)
    return result


def stale_metadata(custom_metadata):
    result = []
    for key, meta in custom_metadata.items():
        if not isinstance(meta, dict):
            continue
        result.append({
            "id": key,
            "key": key,
            "name": str(meta.get("name", pretty_name(key))),
            "description": str(meta.get("description", "Stored metadata for a script that is no longer discovered")),
            "category": str(meta.get("category", "Unavailable")),
            "icon": str(meta.get("icon", "󰅙")),
            "tags": [],
            "favorite": False,
            "hidden": False,
            "confirm": False,
            "executionMode": "normal",
            "timeout": 0,
            "allowMultipleInstances": False,
            "workingDirectory": "",
            "arguments": [],
            "path": str(meta.get("path", "")),
            "sourcePath": str(meta.get("path", "")),
            "command": "",
            "source": "Stored metadata",
            "filename": os.path.basename(str(meta.get("path", key))),
            "extension": "",
            "executable": False,
            "launchable": False,
            "interpreter": "",
            "shebang": "",
            "mtime": 0,
            "kind": "unavailable",
            "available": False,
            "launches": 0,
            "lastUsed": 0,
            "issue": "Script is unavailable"
        })
    return result


def scan_custom_metadata(custom_metadata, state, items):
    for key, meta in custom_metadata.items():
        if key in items or not isinstance(meta, dict):
            continue
        path = os.path.abspath(os.path.expanduser(str(meta.get("path", "")))) if meta.get("path") else ""
        command = str(meta.get("command", "")) if meta.get("command") else ""
        if path and os.path.isfile(path):
            try:
                stat_result = os.stat(path)
            except Exception:
                continue
            shebang = read_shebang(path)
            executable = bool(stat_result.st_mode & 0o111)
            item = make_item(key, path, path, "Stored metadata", "", executable, shebang, stat_result.st_mtime, "custom-script", None, custom_metadata, state)
            item["prefer"] = 3
            if not executable:
                item["issue"] = "Script is not executable"
            items.setdefault(key, []).append(item)
            continue
        resolved = shutil.which(command) if command else ""
        if resolved:
            try:
                stat_result = os.lstat(resolved)
            except Exception:
                continue
            item = make_item(key, resolved, command, "Stored metadata", "", True, "", stat_result.st_mtime, "custom-command", None, custom_metadata, state)
            item["prefer"] = 3
            items.setdefault(key, []).append(item)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True)
    parser.add_argument("--local-config", default="")
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--state", required=True)
    args = parser.parse_args()

    config = load_json(args.config, {})
    local_config = load_json(args.local_config, {})
    custom_metadata = load_json(args.metadata, {})
    state = load_json(args.state, {})

    for key in ("roots", "commands"):
        config.setdefault(key, [])
    config.setdefault("excluded", ["/proc", "/sys", "/dev"])
    config["roots"].extend(local_config.get("roots", []))
    config["commands"].extend(local_config.get("commands", []))
    config["excluded"].extend(local_config.get("excluded", []))

    items = {}
    for root in config["roots"]:
        if isinstance(root, dict):
            scan_root(root, 0, config, custom_metadata, state, items)
    scan_commands(config, custom_metadata, state, items)
    scan_custom_metadata(custom_metadata, state, items)

    discovered_keys = set(items.keys())
    result = merge_items(items)
    for stale in stale_metadata(custom_metadata):
        if stale["id"] not in discovered_keys:
            result.append(stale)

    result.sort(key=lambda item: (item.get("name", "").lower(), item.get("id", "")))
    sys.stdout.write(json.dumps(result, ensure_ascii=False, separators=(",", ":")))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        sys.stderr.write(str(error))
        sys.stdout.write("[]")
