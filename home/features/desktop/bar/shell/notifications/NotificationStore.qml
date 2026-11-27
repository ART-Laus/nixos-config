pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.config
import "NotificationModel.js" as Model

// Owns the desktop notification server and the durable history. Nothing here
// ever removes or expires a row implicitly; only explicit user actions call
// remove/clearHistory. Opening the panel has no effect on unread state.
QtObject {
    id: root

    property var entries: []
    property var state: ({ expandedGroups: {}, view: { category: "all", status: "inbox" } })
    property var rules: ({})
    property var live: ({})
    property bool ready: false
    property bool historyProtected: false
    property int sequence: 0

    readonly property int unreadCount: Model.unreadCount(root.entries)
    readonly property var visibleEntries: Model.visibleEntries(root.entries, root.state.view)
    readonly property var groups: Model.groupRows(root.visibleEntries, root.state.expandedGroups)

    property bool historyLoaded: false
    property bool stateLoaded: false
    property bool rulesLoaded: false

    property bool flushed: false
    property var pendingIncoming: []
    property var pendingWrites: []

    property QtObject internal: Item {
        id: internal

        property NotificationServer server: NotificationServer {
            id: server
            keepOnReload: false
            bodySupported: true
            bodyMarkupSupported: true
            bodyHyperlinksSupported: true
            bodyImagesSupported: true
            actionsSupported: true
            actionIconsSupported: true
            imageSupported: true
            inlineReplySupported: true
            persistenceSupported: true

            onNotification: function (notif) {
                root.receive(notif);
            }
        }

        property FileView historyFile: FileView {
            id: historyFile
            path: Theme.notificationHistoryPath
            watchChanges: false
            atomicWrites: true

            onLoaded: function () {
                root.historyLoaded = true;
                root.loadHistory(text());
            }
            onLoadFailed: function () {
                root.historyLoaded = true;
                root.loadHistory("");
            }
        }

        property FileView stateFile: FileView {
            id: stateFile
            path: Theme.notificationStatePath
            watchChanges: false
            atomicWrites: true

            onLoaded: function () {
                root.stateLoaded = true;
                root.loadState(text());
            }
            onLoadFailed: function () {
                root.stateLoaded = true;
                root.loadState("");
            }
        }

        property FileView rulesFile: FileView {
            id: rulesFile
            path: Theme.notificationRulesPath
            watchChanges: false
            atomicWrites: true

            onLoaded: function () {
                root.rulesLoaded = true;
                root.loadRules(text());
            }
            onLoadFailed: function () {
                root.rulesLoaded = true;
                root.loadRules("");
            }
        }

        property Process mkdirProc: Process {
            id: mkdirProc
            command: [Theme.notificationMkdir, "-p", Theme.notificationDataRoot]
            stdout: StdioCollector {}
            stderr: StdioCollector {}

            onRunningChanged: function () {
                if (!running) root.writeNext();
            }
        }

        property IpcHandler ipc: IpcHandler {
            target: "notificationCenter"

            function open() { UIState.open("notificationCenter"); }
            function close() { UIState.close("notificationCenter"); }
            function toggle() { UIState.open("notificationCenter"); }

            function count(): string {
                return JSON.stringify({ unread: root.unreadCount, total: root.entries.length });
            }

            function list(): string {
                return JSON.stringify(root.visibleEntries.map(function (row) { return root.rowJson(row); }));
            }

            function all(): string {
                return JSON.stringify(root.entries.map(function (row) { return root.rowJson(row); }));
            }

            function groups(): string {
                return JSON.stringify(root.groups.map(function (group) {
                    return {
                        key: group.key, appName: group.appName, chat: group.chat,
                        category: group.category, count: group.count, unread: group.unread,
                        open: group.open, rows: group.rows.length
                    };
                }));
            }

            function toggleGroup(key: string): string {
                root.toggleExpanded(key);
                return "ok";
            }

            function setCategory(appId: string, category: string): string {
                root.setCategory(appId, category);
                return "ok";
            }

            function markRead(key: string): string {
                return root.setStatus(key, "read") ? "ok" : "not found";
            }

            function archive(key: string): string {
                return root.setStatus(key, "archived") ? "ok" : "not found";
            }

            function dismiss(key: string): string {
                return root.setStatus(key, "dismissed") ? "ok" : "not found";
            }

            function remove(key: string): string {
                return root.remove(key) ? "ok" : "not found";
            }

            function archiveInbox(): string {
                root.archiveInbox();
                return "ok";
            }

            function clearHistory(): string {
                root.clearHistory();
                return "ok";
            }

            function setView(category: string, status: string): string {
                root.setView(category, status);
                return "ok";
            }
        }
    }

    Component.onCompleted: root.checkReady()

    function checkReady() {
        if (root.ready) return;
        if (!root.historyLoaded || !root.stateLoaded || !root.rulesLoaded) return;
        root.ready = true;
        root.flushPending();
    }

    function flushPending() {
        if (root.flushed) return;
        root.flushed = true;
        var incoming = root.pendingIncoming.slice();
        root.pendingIncoming = [];
        for (var i = 0; i < incoming.length; i++) root.addRow(incoming[i]);
    }

    function loadHistory(text) {
        var raw = String(text || "");
        // A non-empty but unreadable file must never be overwritten by the
        // next notification. Keep it protected until an explicit clear.
        root.historyProtected = raw.trim().length > 0 && !Model.historyLooksValid(raw);
        root.entries = Model.parseHistory(raw);
        root.sequence = root.entries.length + 1;
        root.checkReady();
    }

    function loadState(text) {
        root.state = Model.parseState(text);
        root.checkReady();
    }

    function loadRules(text) {
        root.rules = Model.parseRules(text);
        root.checkReady();
    }

    function receive(notif) {
        if (!notif) return;
        var now = Date.now();
        if (Model.isReloadDuplicate(root.entries, notif, now)) return;

        notif.tracked = true;
        var keys = root.entries.map(function (row) { return row.key; });
        var row = Model.fromNotification(notif, now, root.sequence, keys, root.rules);
        root.sequence++;

        var actionLabels = [];
        var actions = notif.actions || [];
        for (var i = 0; i < actions.length; i++) {
            actionLabels.push({ label: String(actions[i].text || actions[i].identifier || "Action"), index: i });
        }
        row.actionLabels = actionLabels;

        var nextLive = Object.assign({}, root.live);
        nextLive[row.key] = notif;
        root.live = nextLive;

        // Closing only releases the live Notification object; the history row
        // and its status are untouched and remain persisted.
        notif.closed.connect(function () {
            var remaining = Object.assign({}, root.live);
            delete remaining[row.key];
            root.live = remaining;
        });

        if (!root.ready) {
            root.pendingIncoming = root.pendingIncoming.concat([row]);
            return;
        }
        root.addRow(row);
    }

    function addRow(row) {
        if (!row) return;
        var next = [row].concat(root.entries.filter(function (entry) { return entry && entry.key !== row.key; }));
        next.sort(function (a, b) { return b.timestamp - a.timestamp; });
        root.entries = next;
        root.persistHistory();
    }

    function setStatus(key, status) {
        var next = Model.setStatus(root.entries, key, status);
        if (next === root.entries) return false;
        root.entries = next;
        root.persistHistory();
        return true;
    }

    function setManyStatus(keys, status) {
        var next = Model.setManyStatus(root.entries, keys, status);
        if (next === root.entries) return false;
        root.entries = next;
        root.persistHistory();
        return true;
    }

    function remove(key) {
        var next = Model.remove(root.entries, key);
        if (next.length === root.entries.length) return false;
        root.entries = next;
        var nextLive = Object.assign({}, root.live);
        delete nextLive[key];
        root.live = nextLive;
        root.persistHistory();
        return true;
    }

    function archiveInbox() {
        var keys = [];
        for (var i = 0; i < root.entries.length; i++) {
            if (root.entries[i].status === "unread" || root.entries[i].status === "read") keys.push(root.entries[i].key);
        }
        root.setManyStatus(keys, "archived");
    }

    function clearHistory() {
        // Explicit user action is the only way to discard a protected file.
        root.historyProtected = false;
        root.entries = [];
        root.live = {};
        root.persistHistory();
    }

    function toggleExpanded(groupKey) {
        var next = Object.assign({}, root.state.expandedGroups);
        next[groupKey] = !next[groupKey];
        var view = Object.assign({}, root.state.view);
        root.state = { expandedGroups: next, view: view };
        root.persistState();
    }

    function isExpanded(groupKey) {
        return !!root.state.expandedGroups[groupKey];
    }

    function setView(category, status) {
        var next = Object.assign({}, root.state.view);
        next.category = category === "personal" || category === "system" ? category : "all";
        next.status = status === "archived" || status === "dismissed" || status === "all" ? status : "inbox";
        root.state = { expandedGroups: root.state.expandedGroups, view: next };
        root.persistState();
    }

    function setCategory(appId, category) {
        var clean = category === "personal" ? "personal" : "system";
        var nextRules = Object.assign({}, root.rules);
        nextRules[String(appId).toLowerCase()] = { category: clean };
        root.rules = nextRules;
        root.persistRules();

        var next = root.entries.slice();
        for (var i = 0; i < next.length; i++) {
            if (next[i].appId === appId) {
                var row = Object.assign({}, next[i]);
                row.category = clean;
                next[i] = row;
            }
        }
        root.entries = next;
        root.persistHistory();
    }

    function invokeAction(key, index) {
        var notif = root.live[key];
        if (!notif) return false;
        var actions = notif.actions || [];
        if (index < 0 || index >= actions.length) return false;
        actions[index].invoke();
        return true;
    }

    function dismissLive(key) {
        var notif = root.live[key];
        if (notif) notif.dismiss();
    }

    function rowJson(row) {
        return {
            key: row.key, appName: row.appName, sender: row.sender, chat: row.chat,
            summary: row.summary, body: row.body, category: row.category,
            status: row.status, timestamp: row.timestamp
        };
    }

    function queueWrite(path, text) {
        var next = [];
        for (var i = 0; i < root.pendingWrites.length; i++) {
            if (root.pendingWrites[i].path !== path) next.push(root.pendingWrites[i]);
        }
        next.push({ path: path, text: text });
        root.pendingWrites = next;
        root.pump();
    }

    function pump() {
        if (mkdirProc.running || root.pendingWrites.length === 0) return;
        mkdirProc.running = true;
    }

    function writeNext() {
        if (mkdirProc.running || root.pendingWrites.length === 0) return;
        var entry = root.pendingWrites.shift();
        if (entry.path === Theme.notificationHistoryPath) historyFile.setText(entry.text);
        else if (entry.path === Theme.notificationStatePath) stateFile.setText(entry.text);
        else if (entry.path === Theme.notificationRulesPath) rulesFile.setText(entry.text);
        root.pump();
    }

    function persistHistory() {
        if (root.historyProtected) return;
        root.queueWrite(Theme.notificationHistoryPath, Model.serialiseHistory(root.entries));
    }

    function persistState() {
        root.queueWrite(Theme.notificationStatePath, Model.serialiseState(root.state));
    }

    function persistRules() {
        root.queueWrite(Theme.notificationRulesPath, JSON.stringify({ version: Model.VERSION, overrides: root.rules }, null, 2) + "\n");
    }
}
