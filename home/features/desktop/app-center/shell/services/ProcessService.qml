pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config
import "../core/FuzzySearch.js" as FuzzySearch

QtObject {
    id: root

    property var totals: ({
        cpu_percent: 0,
        memory_used: 0,
        memory_total: 0,
        memory_percent: 0,
        swap_used: 0,
        swap_total: 0,
        swap_percent: 0,
        loadavg: [0, 0, 0]
    })
    property var processes: []
    property var visibleProcesses: []
    property var lastResult: ({})
    property string query: ""
    property string sortColumn: "cpu_percent"
    property bool sortDescending: true
    property bool backendReady: false
    readonly property bool backendRunning: internal.backend.running

    signal snapshotReceived()
    signal resultReceived(var result)

    property QtObject internal: Item {
        id: internal

        property Process backend: Process {
            id: backend
            command: [Theme.processBackend]
            stdinEnabled: true
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: function (line) {
                    root.parseLine(line);
                }
            }
            stderr: StdioCollector {}

            onRunningChanged: function () {
                if (running) {
                    root.backendReady = false;
                } else {
                    root.backendReady = false;
                    root.processes = [];
                    root.visibleProcesses = [];
                }
            }
        }

        property Timer stopTimer: Timer {
            id: stopTimer
            interval: 400
            onTriggered: function () {
                if (internal.backend.running)
                    internal.backend.running = false;
            }
        }
    }

    onQueryChanged: root.refreshVisible()
    onSortColumnChanged: root.refreshVisible()
    onSortDescendingChanged: root.refreshVisible()

    function start() {
        if (!internal.backend.running)
            internal.backend.running = true;
        else
            root.send({ cmd: "resume" });
    }

    function stop() {
        if (!internal.backend.running)
            return;
        root.send({ cmd: "quit" });
        internal.stopTimer.restart();
    }

    function send(obj) {
        if (!internal.backend.running)
            return;
        internal.backend.write(JSON.stringify(obj) + "\n");
    }

    function parseLine(line) {
        if (!line || line.trim().length === 0)
            return;
        var obj = null;
        try {
            obj = JSON.parse(line);
        } catch (e) {
            return;
        }
        if (!obj || typeof obj !== "object")
            return;
        if (obj.type === "ready") {
            root.backendReady = true;
            root.send({ cmd: "snapshot", interval: AppSettings.processIntervalMs / 1000 });
        } else if (obj.type === "snapshot") {
            root.totals = obj.totals || root.totals;
            root.processes = obj.processes || [];
            root.refreshVisible();
            root.snapshotReceived();
        } else if (obj.type === "result") {
            root.lastResult = obj;
            root.resultReceived(obj);
        }
    }

    function matches(row, query) {
        if (query.length === 0)
            return true;
        var name = FuzzySearch.normalize(row.name || "");
        var pid = String(row.pid || "");
        var user = FuzzySearch.normalize(row.user || "");
        var cmd = FuzzySearch.normalize(row.cmdline || "");
        return name.indexOf(query) >= 0 || pid.indexOf(query) >= 0 || user.indexOf(query) >= 0 || cmd.indexOf(query) >= 0;
    }

    function compareRows(a, b) {
        var column = root.sortColumn;
        var av = a[column];
        var bv = b[column];
        if (typeof av === "string" || typeof bv === "string") {
            av = String(av || "");
            bv = String(bv || "");
            var textCmp = av.localeCompare(bv);
            return root.sortDescending ? -textCmp : textCmp;
        }
        av = Number(av) || 0;
        bv = Number(bv) || 0;
        return root.sortDescending ? bv - av : av - bv;
    }

    function refreshVisible() {
        var query = FuzzySearch.normalize(root.query);
        var rows = [];
        var list = root.processes || [];
        for (var i = 0; i < list.length; i++) {
            if (root.matches(list[i], query))
                rows.push(list[i]);
        }
        rows.sort(root.compareRows);
        root.visibleProcesses = rows;
    }

    function setSort(column) {
        if (root.sortColumn === column)
            root.sortDescending = !root.sortDescending;
        else {
            root.sortColumn = column;
            root.sortDescending = true;
        }
    }

    function signalProcess(row, sig, acknowledgeCritical) {
        if (!row)
            return;
        root.send({
            cmd: "signal",
            pid: row.pid,
            start_time: row.start_time,
            sig: sig,
            acknowledge_critical: acknowledgeCritical === true
        });
    }

    function startProcess(argv, cwd) {
        root.send({ cmd: "start", argv: argv, cwd: cwd || "" });
    }

    function startShell(command, cwd) {
        root.send({ cmd: "start_shell", command: command, cwd: cwd || "" });
    }

    function snapshotOnce() {
        root.send({ cmd: "snapshot", once: true });
    }
}
