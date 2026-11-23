pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

QtObject {
    id: root

    property var data: ({})
    property string pendingWrite: ""
    signal usageChanged()

    property QtObject internal: Item {
        id: internal

        property FileView file: FileView {
            id: file
            path: Theme.usagePath
            onLoaded: function () {
                try {
                    var parsed = JSON.parse(file.text());
                    root.data = parsed && typeof parsed === "object" ? parsed : {};
                } catch (e) {
                    root.data = {};
                }
                root.usageChanged();
            }
            onLoadFailed: function () {
                root.data = {};
                root.usageChanged();
                root.persistNow();
            }
        }

        property Timer persistTimer: Timer {
            id: persistTimer
            interval: 800
            onTriggered: root.persistNow()
        }

        property Process mkdirProc: Process {
            id: mkdirProc
            command: ["mkdir", "-p", root.dirOf(Theme.usagePath)]
            stdout: StdioCollector {}
            stderr: StdioCollector {}

            onRunningChanged: function () {
                if (!running && root.pendingWrite.length > 0) {
                    file.setText(root.pendingWrite);
                    root.pendingWrite = "";
                }
            }
        }
    }

    function dirOf(path) {
        var parts = String(path).split("/");
        parts.pop();
        return parts.join("/") || "/";
    }

    function persistNow() {
        root.pendingWrite = JSON.stringify(root.data);
        internal.mkdirProc.running = false;
        internal.mkdirProc.running = true;
    }

    function schedulePersist() {
        internal.persistTimer.restart();
    }

    function usage(id) {
        var value = root.data[id];
        if (!value || typeof value !== "object")
            return { launches: 0, lastUsed: 0, firstUsed: 0, recentAt: 0 };
        return {
            launches: value.launches || 0,
            lastUsed: value.lastUsed || 0,
            firstUsed: value.firstUsed || 0,
            recentAt: value.recentAt || value.lastUsed || 0
        };
    }

    function record(id, name) {
        if (!id)
            return;
        var now = Date.now();
        var value = root.data[id];
        if (!value || typeof value !== "object")
            value = { id: id, name: name || id, launches: 0, firstUsed: now, lastUsed: 0, recentAt: 0 };
        value.name = name || value.name || id;
        value.launches = (value.launches || 0) + 1;
        value.lastUsed = now;
        value.recentAt = now;
        root.data[id] = value;
        root.usageChanged();
        root.schedulePersist();
    }

    function touch(id, name) {
        if (!id)
            return;
        var now = Date.now();
        var value = root.data[id];
        if (!value || typeof value !== "object")
            value = { id: id, name: name || id, launches: 0, firstUsed: now, lastUsed: 0, recentAt: 0 };
        value.name = name || value.name || id;
        value.lastUsed = now;
        value.recentAt = now;
        root.data[id] = value;
        root.usageChanged();
        root.schedulePersist();
    }

    function recent(limit) {
        var rows = [];
        for (var key in root.data) {
            var value = root.data[key];
            if (!value || typeof value !== "object")
                continue;
            rows.push({
                id: key,
                name: value.name || key,
                launches: value.launches || 0,
                firstUsed: value.firstUsed || 0,
                lastUsed: value.lastUsed || 0,
                recentAt: value.recentAt || value.lastUsed || 0
            });
        }
        rows.sort(function (a, b) {
            return b.recentAt - a.recentAt;
        });
        return rows.slice(0, limit || AppSettings.recentLimit);
    }
}
