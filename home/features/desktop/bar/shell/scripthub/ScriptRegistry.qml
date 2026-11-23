pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.scripthub

QtObject {
    id: root

    property var scripts: []
    property bool ready: false
    property bool refreshing: false
    property string errorMessage: ""
    property int lastRefresh: 0
    property string search: ""
    property string selectedCategory: "All"
    property string sortMode: "favorites"
    property bool showHidden: false
    property var selectedScript: ({})

    signal scriptsUpdated()
    signal selectedScriptUpdated()
    signal refreshFinished()

    property var filteredScripts: root.applyFilters(root.scripts, root.search, root.selectedCategory, root.sortMode, root.showHidden, ScriptStore.state, ScriptStore.metadata)
    property var categories: root.buildCategories(root.scripts, ScriptStore.state, ScriptStore.metadata)

    property Process discoverProc: Process {
        id: discoverProc
        command: [
            Theme.scriptHubDiscover,
            "--config", Theme.scriptHubConfigPath,
            "--local-config", Theme.scriptHubLocalConfigPath,
            "--metadata", Theme.scriptHubMetadataPath,
            "--state", Theme.scriptHubStatePath
        ]
        stdout: StdioCollector {
            id: discoverOut
            onStreamFinished: function () {
                try {
                    var parsed = JSON.parse(this.text);
                    root.scripts = Array.isArray(parsed) ? parsed : [];
                    root.errorMessage = "";
                    root.ready = true;
                    root.scriptsUpdated();
                    root.refreshFinished();
                    if (!root.findById(root.selectedScript.id).id) root.selectedScript = root.filteredScripts.length > 0 ? root.filteredScripts[0] : ({});
                } catch (e) {
                    root.errorMessage = "Failed to parse discovery output";
                    root.refreshing = false;
                }
            }
        }
        stderr: StdioCollector {
            id: discoverErr
            onStreamFinished: function () {
                if (this.text.trim().length > 0) root.errorMessage = this.text.trim();
            }
        }
        onRunningChanged: function () {
            root.refreshing = running;
            if (!running) {
                root.lastRefresh = Date.now();
                root.refreshFinished();
            }
        }
    }

    property Timer refreshDebounce: Timer {
        id: refreshDebounce
        interval: 80
        repeat: false
        onTriggered: {
            if (!discoverProc.running) discoverProc.running = true;
        }
    }

    Component.onCompleted: root.refresh()

    function refresh() {
        refreshDebounce.restart();
    }

    function findById(id) {
        if (!id) return ({});
        for (var i = 0; i < root.scripts.length; i++) {
            if (root.scripts[i].id === id) return root.scripts[i];
        }
        return ({});
    }

    function displayName(id) {
        var script = root.findById(id);
        return script.name || id || "Unknown script";
    }

    function isFavorite(script) {
        if (!script || !script.id) return false;
        return ScriptStore.isFavorite(script.id) || !!script.favorite;
    }

    function isHidden(script) {
        if (!script || !script.id) return !!script.hidden;
        var meta = ScriptStore.metadataFor(script.id);
        return meta.hasOwnProperty("hidden") ? !!meta.hidden : !!script.hidden;
    }

    function effectiveMeta(script) {
        if (!script || !script.id) return ({});
        var base = JSON.parse(JSON.stringify(script));
        var meta = ScriptStore.metadataFor(script.id);
        for (var key in meta) base[key] = meta[key];
        base.favorite = root.isFavorite(script);
        return base;
    }

    function matches(script, needle) {
        if (!needle) return true;
        var haystack = [script.name, script.description, script.category, script.filename, script.id, script.source].concat(script.tags || []).join(" ").toLowerCase();
        return haystack.indexOf(needle) >= 0;
    }

    function applyFilters(scripts, search, category, sortMode, showHidden, state, metadata) {
        var needle = String(search || "").trim().toLowerCase();
        var rows = [];
        for (var i = 0; i < scripts.length; i++) {
            var script = root.effectiveMeta(scripts[i]);
            if (!showHidden && root.isHidden(script)) continue;
            if (category && category !== "All" && script.category !== category) continue;
            if (!root.matches(script, needle)) continue;
            rows.push(script);
        }
        rows.sort(function (a, b) {
            var af = root.isFavorite(a) ? 1 : 0;
            var bf = root.isFavorite(b) ? 1 : 0;
            if (sortMode === "name") return String(a.name).localeCompare(String(b.name));
            if (sortMode === "category") {
                var categoryCompare = String(a.category).localeCompare(String(b.category));
                return categoryCompare !== 0 ? categoryCompare : String(a.name).localeCompare(String(b.name));
            }
            if (sortMode === "recent") return (b.lastUsed || 0) - (a.lastUsed || 0);
            if (sortMode === "launches") return (b.launches || 0) - (a.launches || 0);
            if (af !== bf) return bf - af;
            return String(a.name).localeCompare(String(b.name));
        });
        return rows;
    }

    function buildCategories(scripts, state, metadata) {
        var counts = ({});
        for (var i = 0; i < scripts.length; i++) {
            var script = root.effectiveMeta(scripts[i]);
            if (root.isHidden(script)) continue;
            var category = script.category || "Uncategorized";
            counts[category] = (counts[category] || 0) + 1;
        }
        var rows = [{ name: "All", count: scripts.length }];
        for (var key in counts) rows.push({ name: key, count: counts[key] });
        rows.sort(function (a, b) {
            if (a.name === "All") return -1;
            if (b.name === "All") return 1;
            return a.name.localeCompare(b.name);
        });
        return rows;
    }

    function select(script) {
        root.selectedScript = script || ({});
        root.selectedScriptUpdated();
    }

    function selectById(id) {
        root.select(root.findById(id));
    }

    function toggleFavorite(script) {
        if (script && script.id) ScriptStore.toggleFavorite(script.id);
    }

    function setHidden(script, value) {
        if (!script || !script.id) return;
        var meta = root.effectiveMeta(script);
        meta.hidden = !!value;
        ScriptStore.setMetadata(script.id, meta, script);
        refreshDebounce.restart();
    }

    function saveMetadata(script, meta) {
        if (!script || !script.id) return;
        ScriptStore.setMetadata(script.id, meta, script);
        refreshDebounce.restart();
    }

    function forget(script) {
        if (!script || !script.id) return;
        ScriptStore.forget(script.id);
        refreshDebounce.restart();
    }

    function run(script, values) {
        if (!script || !script.launchable) return null;
        return ScriptExecutor.run(script, values);
    }
}
