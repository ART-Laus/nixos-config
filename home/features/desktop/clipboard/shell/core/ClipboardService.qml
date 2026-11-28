pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

QtObject {
    id: root

    property var entries: []
    property var counts: ({ all: 0, pinned: 0, text: 0, images: 0, links: 0, unpinned: 0 })
    property var detailEntry: null
    property int pausedFor: 0
    property bool backendOk: false
    property string lastError: ""

    property var queue: []
    property var pending: null

    signal listChanged()
    signal commandFinished(string cmd, var response)
    signal entryReceived(var entry)

    function refresh() {
        root.send("list", [], function (res) { });
    }

    function send(cmd, args, callback) {
        root.queue.push({ cmd: cmd, args: args || [], callback: callback });
        root.pump();
    }

    function pump() {
        if (root.pending || ctl.running || root.queue.length === 0)
            return;
        root.pending = root.queue.shift();
        ctl.command = [Theme.clipboardCtl, root.pending.cmd].concat(root.pending.args);
        commandTimeout.restart();
        ctl.running = false;
        ctl.running = true;
    }

    function finish(text) {
        if (!root.pending)
            return;
        commandTimeout.stop();
        var job = root.pending;
        root.pending = null;
        var res = { ok: false, error: "no response" };
        try {
            var lines = String(text || "").split("\n");
            for (var i = 0; i < lines.length; i++) {
                if (lines[i].trim().length === 0)
                    continue;
                var parsed = JSON.parse(lines[i]);
                if (parsed && typeof parsed === "object") {
                    res = parsed;
                    break;
                }
            }
        } catch (e) {
            res = { ok: false, error: "bad response" };
        }
        if (res.type === "list") {
            root.entries = res.entries || [];
            root.counts = res.counts || root.counts;
            root.pausedFor = Number(res.pausedFor) || 0;
            root.backendOk = true;
            root.lastError = "";
            root.listChanged();
        } else if (res.type === "entry") {
            root.detailEntry = res.entry || null;
            root.entryReceived(root.detailEntry);
        } else if (res.type === "status") {
            root.counts = res.counts || root.counts;
            root.pausedFor = Number(res.pausedFor) || 0;
            root.backendOk = !!res.ok;
        } else if (res.ok === false) {
            root.lastError = String(res.error || "error");
        }
        root.commandFinished(String(job.cmd), res);
        if (job.callback)
            job.callback(res);
        ctl.running = false;
        root.pump();
    }

    function restore(id) {
        root.send("restore", [id], function () { root.refresh(); });
    }

    function pin(id, pinned) {
        root.send("pin", [id, pinned ? "1" : "0"], function () { root.refresh(); });
    }

    function remove(id) {
        root.send("delete", [id], function () { root.refresh(); });
    }

    function clearUnpinned(all) {
        root.send("clear", all ? ["all"] : [], function () { root.refresh(); });
    }

    function get(id) {
        root.detailEntry = null;
        root.send("get", [id], function () { });
    }

    function privacy(seconds) {
        var args = seconds > 0 ? ["pause", String(seconds)] : [];
        root.send("privacy", args, function () { root.refresh(); });
    }

    property QtObject internal: Item {
        id: internal

        property Timer commandTimeout: Timer {
            id: commandTimeout
            interval: 5000
            onTriggered: function () {
                if (root.pending)
                    root.finish("");
            }
        }

        property Process ctl: Process {
            id: ctl
            command: []
            stdout: StdioCollector {
                onStreamFinished: function () { root.finish(text); }
            }
            stderr: StdioCollector { }
        }

        // Long-lived event stream: capture happens in the daemon whether or
        // not the window is open, and the UI stays in sync without polling.
        property Process subscriber: Process {
            id: subscriber
            command: [Theme.clipboardCtl, "subscribe"]
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: function (line) {
                    if (String(line).indexOf('"event":"changed"') >= 0)
                        root.refresh();
                }
            }
            stderr: StdioCollector { }
        }
    }

    Component.onCompleted: {
        internal.subscriber.running = true;
        root.send("status", [], function () { root.refresh(); });
    }
}
