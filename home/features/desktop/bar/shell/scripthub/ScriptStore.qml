pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

QtObject {
    id: root

    property var metadata: ({})
    property var state: ({ favorites: [], recent: [], usage: {} })
    property var history: []
    property bool ready: false

    signal metadataUpdated()
    signal stateUpdated()
    signal historyUpdated()

    property QtObject internal: Item {
        id: internal

        property FileView metadataFile: FileView {
            id: metadataFile
            path: Theme.scriptHubMetadataPath
            watchChanges: true
            onFileChanged: reload()
            onLoaded: function () {
                try {
                    var parsed = JSON.parse(metadataFile.text());
                    root.metadata = parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {};
                } catch (e) {
                    root.metadata = {};
                }
                root.metadataUpdated();
                root.checkReady();
            }
            onLoadFailed: function () {
                root.metadata = {};
                root.metadataUpdated();
                root.checkReady();
            }
        }

        property FileView stateFile: FileView {
            id: stateFile
            path: Theme.scriptHubStatePath
            watchChanges: true
            onFileChanged: reload()
            onLoaded: function () {
                root.state = root.normalizeState(stateFile.text());
                root.stateUpdated();
                root.checkReady();
            }
            onLoadFailed: function () {
                root.state = root.emptyState();
                root.stateUpdated();
                root.checkReady();
            }
        }

        property FileView historyFile: FileView {
            id: historyFile
            path: Theme.scriptHubHistoryPath
            watchChanges: true
            onFileChanged: reload()
            onLoaded: function () {
                try {
                    var parsed = JSON.parse(historyFile.text());
                    root.history = Array.isArray(parsed) ? parsed : [];
                } catch (e) {
                    root.history = [];
                }
                root.historyUpdated();
                root.checkReady();
            }
            onLoadFailed: function () {
                root.history = [];
                root.historyUpdated();
                root.checkReady();
            }
        }

        property Process mkdirProc: Process {
            id: mkdirProc
            command: [Theme.scriptHubMkdir, "-p", Theme.scriptHubDataRoot]
            stdout: StdioCollector {}
            stderr: StdioCollector {}
            onRunningChanged: function () {
                if (running) return;
                root.writeNext();
            }
        }

        property Process backupProc: Process {
            id: backupProc
            stdout: StdioCollector {}
            stderr: StdioCollector {}
            onRunningChanged: function () {
                if (running) return;
                root.pump();
            }
        }
    }

    property var pendingWrites: []
    property var pendingBackups: []
    property var backedUp: ({})

    Component.onCompleted: root.checkReady()

    function checkReady() {
        root.ready = metadataFile.status !== FileView.Loading && stateFile.status !== FileView.Loading && historyFile.status !== FileView.Loading;
    }

    function emptyState() {
        return { favorites: [], recent: [], usage: {} };
    }

    function normalizeState(text) {
        try {
            var parsed = JSON.parse(text);
            if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return root.emptyState();
            return {
                favorites: Array.isArray(parsed.favorites) ? parsed.favorites : [],
                recent: Array.isArray(parsed.recent) ? parsed.recent : [],
                usage: parsed.usage && typeof parsed.usage === "object" && !Array.isArray(parsed.usage) ? parsed.usage : {}
            };
        } catch (e) {
            return root.emptyState();
        }
    }

    function queueWrite(path, text) {
        var next = [];
        for (var i = 0; i < root.pendingWrites.length; i++) {
            if (root.pendingWrites[i].path !== path) next.push(root.pendingWrites[i]);
        }
        next.push({ path: path, text: text });
        root.pendingWrites = next;
        if (!root.backedUp[path]) {
            root.pendingBackups.push(path);
            root.backedUp[path] = true;
        }
        root.pump();
    }

    function pump() {
        if (backupProc.running || mkdirProc.running) return;
        if (root.pendingBackups.length > 0) {
            var backupPath = root.pendingBackups.shift();
            backupProc.command = [Theme.scriptHubCp, "-n", backupPath, backupPath + ".bak"];
            backupProc.running = true;
            return;
        }
        if (root.pendingWrites.length > 0) {
            mkdirProc.running = true;
        }
    }

    function writeNext() {
        if (mkdirProc.running || backupProc.running || root.pendingBackups.length > 0 || root.pendingWrites.length === 0) {
            root.pump();
            return;
        }
        var entry = root.pendingWrites.shift();
        if (entry.path === Theme.scriptHubMetadataPath) metadataFile.setText(entry.text);
        else if (entry.path === Theme.scriptHubStatePath) stateFile.setText(entry.text);
        else if (entry.path === Theme.scriptHubHistoryPath) historyFile.setText(entry.text);
        root.pump();
    }

    function persistMetadata() {
        queueWrite(Theme.scriptHubMetadataPath, JSON.stringify(root.metadata, null, 2));
    }

    function persistState() {
        queueWrite(Theme.scriptHubStatePath, JSON.stringify(root.state, null, 2));
    }

    function persistHistory() {
        queueWrite(Theme.scriptHubHistoryPath, JSON.stringify(root.history, null, 2));
    }

    function metadataFor(id) {
        if (!id) return ({});
        var value = root.metadata[id];
        return value && typeof value === "object" ? JSON.parse(JSON.stringify(value)) : ({});
    }

    function sanitizeMetadata(value) {
        var result = value && typeof value === "object" && !Array.isArray(value) ? JSON.parse(JSON.stringify(value)) : {};
        if (Array.isArray(result.arguments)) {
            for (var i = 0; i < result.arguments.length; i++) {
                var arg = result.arguments[i];
                if (arg && arg.type === "password" && arg.hasOwnProperty("default")) delete arg.default;
            }
        }
        return result;
    }

    function setMetadata(id, value, script) {
        if (!id) return;
        var clean = root.sanitizeMetadata(value);
        if (script) {
            if (!clean.path && script.path) clean.path = script.path;
            if (!clean.command && script.command) clean.command = script.command;
        }
        var next = JSON.parse(JSON.stringify(root.metadata));
        next[id] = clean;
        root.metadata = next;
        root.metadataUpdated();
        root.persistMetadata();
    }

    function removeMetadata(id) {
        var next = JSON.parse(JSON.stringify(root.metadata));
        delete next[id];
        root.metadata = next;
        root.metadataUpdated();
        root.persistMetadata();
    }

    function isFavorite(id) {
        return root.state.favorites.indexOf(id) >= 0;
    }

    function setFavorite(id, value) {
        var favorites = root.state.favorites.slice();
        var index = favorites.indexOf(id);
        if (value && index < 0) favorites.push(id);
        if (!value && index >= 0) favorites.splice(index, 1);
        var next = JSON.parse(JSON.stringify(root.state));
        next.favorites = favorites;
        root.state = next;
        root.stateUpdated();
        root.persistState();
    }

    function toggleFavorite(id) {
        root.setFavorite(id, !root.isFavorite(id));
    }

    function usage(id) {
        var value = root.state.usage[id];
        if (!value || typeof value !== "object") return { launches: 0, firstUsed: 0, lastUsed: 0 };
        return {
            launches: value.launches || 0,
            firstUsed: value.firstUsed || 0,
            lastUsed: value.lastUsed || 0
        };
    }

    function recordLaunch(id, name) {
        if (!id) return;
        var now = Date.now();
        var next = JSON.parse(JSON.stringify(root.state));
        var value = next.usage[id];
        if (!value || typeof value !== "object") value = { launches: 0, firstUsed: now, lastUsed: 0 };
        value.launches = (value.launches || 0) + 1;
        value.lastUsed = now;
        if (!value.firstUsed) value.firstUsed = now;
        next.usage[id] = value;
        var recent = next.recent.filter(function (entry) { return entry !== id; });
        recent.unshift(id);
        next.recent = recent.slice(0, 40);
        root.state = next;
        root.stateUpdated();
        root.persistState();
    }

    function recentIds(limit) {
        var rows = [];
        for (var key in root.state.usage) {
            var used = root.state.usage[key];
            if (used && typeof used === "object") rows.push({ id: key, lastUsed: used.lastUsed || 0 });
        }
        rows.sort(function (a, b) { return b.lastUsed - a.lastUsed; });
        return rows.slice(0, limit || 12).map(function (row) { return row.id; });
    }

    function recordHistory(entry) {
        var next = root.history.slice();
        next.unshift(entry);
        root.history = next.slice(0, 100);
        root.historyUpdated();
        root.persistHistory();
    }

    function clearHistory() {
        root.history = [];
        root.historyUpdated();
        root.persistHistory();
    }

    function forget(id) {
        root.removeMetadata(id);
        var next = JSON.parse(JSON.stringify(root.state));
        delete next.usage[id];
        next.favorites = next.favorites.filter(function (entry) { return entry !== id; });
        next.recent = next.recent.filter(function (entry) { return entry !== id; });
        root.state = next;
        root.stateUpdated();
        root.persistState();
    }
}
