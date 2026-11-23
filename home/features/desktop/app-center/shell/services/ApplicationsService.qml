pragma Singleton
import QtQuick
import Quickshell
import qs.config
import qs.appcenter.core
import "../core/FuzzySearch.js" as FuzzySearch

QtObject {
    id: root

    property var entries: []
    property var byId: ({})
    signal catalogChanged()

    property QtObject internal: Item {
        Connections {
            target: DesktopEntries.applications
            function onValuesChanged() {
                root.rebuild();
            }
        }
    }

    Component.onCompleted: root.rebuild()

    function rebuild() {
        var list = [];
        var map = {};
        var values = DesktopEntries.applications.values || [];
        for (var i = 0; i < values.length; i++) {
            var entry = values[i];
            if (!entry || entry.noDisplay)
                continue;
            list.push(entry);
            map[entry.id] = entry;
        }
        root.entries = list;
        root.byId = map;
        root.catalogChanged();
    }

    function refresh() {
        root.rebuild();
    }

    function iconSource(entry) {
        if (!entry)
            return "";
        return Quickshell.iconPath(entry.icon || "application-x-executable");
    }

    function ranked() {
        var now = Date.now();
        var rows = root.entries.slice();
        rows.sort(function (a, b) {
            var cmp = Ranking.compare(UsageStore.usage(a.id), UsageStore.usage(b.id), now);
            if (cmp !== 0)
                return cmp;
            return String(a.name || "").localeCompare(String(b.name || ""));
        });
        return rows;
    }

    function recent() {
        var rows = [];
        var recentUsage = UsageStore.recent(AppSettings.recentLimit);
        for (var i = 0; i < recentUsage.length; i++) {
            var entry = root.byId[recentUsage[i].id];
            if (!entry)
                continue;
            rows.push(entry);
        }
        return rows;
    }

    function filtered(query) {
        var text = FuzzySearch.normalize(query);
        if (text.length === 0) {
            var rankedRows = root.ranked();
            var plain = [];
            for (var r = 0; r < rankedRows.length; r++)
                plain.push({ entry: rankedRows[r], score: 0, indices: [] });
            return plain;
        }

        var results = [];
        for (var i = 0; i < root.entries.length; i++) {
            var entry = root.entries[i];
            var fields = [
                { text: entry.name || "", weight: 1.35 },
                { text: entry.genericName || "", weight: 0.9 },
                { text: entry.comment || "", weight: 0.7 },
                { text: (entry.keywords || []).join(" "), weight: 0.85 },
                { text: (entry.categories || []).join(" "), weight: 0.55 },
                { text: entry.id || "", weight: 0.65 }
            ];
            var match = FuzzySearch.best(text, fields);
            if (!match)
                continue;
            var boost = Ranking.usageScore(UsageStore.usage(entry.id), Date.now()) * 1.5;
            results.push({ entry: entry, score: match.score + boost, indices: match.indices, fieldIndex: match.fieldIndex });
        }
        results.sort(function (a, b) {
            return b.score - a.score;
        });
        return results;
    }

    function launch(entry) {
        if (!entry)
            return;
        UsageStore.record(entry.id, entry.name);
        var command = entry.command || [];
        if (entry.runInTerminal && command.length > 0) {
            Quickshell.execDetached({
                command: ["alacritty", "-e"].concat(command),
                workingDirectory: entry.workingDirectory || ""
            });
        } else {
            entry.execute();
        }
        Qt.callLater(function () {
            AppState.close();
        });
    }

    function launchAction(entry, actionId) {
        if (!entry || !entry.actions)
            return;
        for (var i = 0; i < entry.actions.length; i++) {
            if (entry.actions[i].id === actionId) {
                UsageStore.record(entry.id, entry.name);
                entry.actions[i].execute();
                Qt.callLater(function () {
                    AppState.close();
                });
                return;
            }
        }
    }

    function lookupClass(windowClass) {
        if (!windowClass)
            return null;
        var value = String(windowClass).split(" ")[0];
        if (root.byId[value + ".desktop"])
            return root.byId[value + ".desktop"];
        var byId = DesktopEntries.byId(value + ".desktop");
        if (byId)
            return byId;
        return DesktopEntries.heuristicLookup(value);
    }

    function touchClass(windowClass) {
        var entry = root.lookupClass(windowClass);
        if (entry)
            UsageStore.touch(entry.id, entry.name);
    }
}
