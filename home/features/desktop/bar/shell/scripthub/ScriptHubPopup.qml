import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.scripthub

Item {
    id: root

    property bool editing: false
    property bool editingNew: false
    property bool confirmRun: false
    property bool confirmForget: false
    property string statusMessage: ""
    property var selected: ScriptRegistry.effectiveMeta(ScriptRegistry.selectedScript)

    signal requestClose()

    focus: true

    IpcHandler {
        target: "scriptHub"

        function open() {
            UIState.open("scriptHub");
        }

        function close() {
            UIState.close("scriptHub");
        }

        function toggle() {
            UIState.open("scriptHub");
        }

        function refresh() {
            ScriptRegistry.refresh();
        }

        function list(): string {
            var rows = [];
            for (var i = 0; i < ScriptRegistry.scripts.length; i++) {
                var script = ScriptRegistry.scripts[i];
                rows.push({ id: script.id, name: script.name, category: script.category, launchable: script.launchable });
            }
            return JSON.stringify(rows);
        }

        function run(id: string): string {
            var script = ScriptRegistry.findById(id);
            if (!script.id) return "Script not found";
            if (!script.launchable) return "Script is not launchable";
            return ScriptExecutor.run(script, {}) || "Started " + script.name;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.pillBase.r, Theme.pillBase.g, Theme.pillBase.b, 0.85)
        radius: Settings.popupRadius
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                color: Theme.primary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                text: "󰘲  Script Hub"
            }

            HubButton {
                compact: true
                label: "Add"
                icon: "＋"
                onClicked: {
                    root.editingNew = true;
                    root.editing = true;
                }
            }

            HubButton {
                compact: true
                label: "Refresh"
                icon: "󰅱"
                onClicked: ScriptRegistry.refresh()
            }

            HubButton {
                compact: true
                label: "Close"
                icon: "×"
                onClicked: root.requestClose()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            HubField {
                Layout.fillWidth: true
                placeholder: "Search scripts, tags, descriptions..."
                text: ScriptRegistry.search
                onTextEdited: function (value) { ScriptRegistry.search = value; }
            }

            HubButton {
                compact: true
                label: "Favorites"
                active: ScriptRegistry.sortMode === "favorites"
                onClicked: ScriptRegistry.sortMode = "favorites"
            }

            HubButton {
                compact: true
                label: "Recent"
                active: ScriptRegistry.sortMode === "recent"
                onClicked: ScriptRegistry.sortMode = "recent"
            }

            HubButton {
                compact: true
                label: "Name"
                active: ScriptRegistry.sortMode === "name"
                onClicked: ScriptRegistry.sortMode = "name"
            }

            HubButton {
                compact: true
                label: "Hidden"
                active: ScriptRegistry.showHidden
                onClicked: ScriptRegistry.showHidden = !ScriptRegistry.showHidden
            }
        }

        Flickable {
            id: categoryStrip
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            contentWidth: categoryRow.implicitWidth
            contentHeight: 26
            clip: true
            flickableDirection: Flickable.HorizontalFlick

            Row {
                id: categoryRow
                height: 26
                spacing: 5

                Repeater {
                    model: ScriptRegistry.categories

                    HubButton {
                        required property var modelData
                        compact: true
                        label: modelData.name + "  " + modelData.count
                        active: ScriptRegistry.selectedCategory === modelData.name
                        onClicked: ScriptRegistry.selectedCategory = modelData.name
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 238
                Layout.fillHeight: true
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.2)
                border.width: 1
                border.color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.07)

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 6
                    contentWidth: width
                    contentHeight: scriptList.implicitHeight
                    clip: true

                    Column {
                        id: scriptList
                        width: parent.width
                        spacing: 5

                        Repeater {
                            id: scriptListRepeater
                            model: ScriptRegistry.filteredScripts

                            ScriptCard {
                                required property var modelData
                                script: modelData
                                selected: root.selected && root.selected.id === modelData.id
                                running: ScriptExecutor.activeFor(modelData.id) !== null
                                onClicked: ScriptRegistry.select(modelData)
                                onRunClicked: root.runScript(modelData)
                                onFavoriteClicked: ScriptRegistry.toggleFavorite(modelData)
                                onEditClicked: {
                                    ScriptRegistry.select(modelData);
                                    root.editingNew = false;
                                    root.editing = true;
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                            wrapMode: Text.Wrap
                            text: ScriptRegistry.errorMessage || "No scripts match this filter"
                            visible: scriptListRepeater.count === 0
                        }

                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: Qt.rgba(0, 0, 0, 0.2)
                border.width: 1
                border.color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.07)

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 10
                    contentWidth: width
                    contentHeight: details.implicitHeight
                    clip: true

                    Column {
                        id: details
                        width: parent.width
                        spacing: 8

                        Text {
                            width: parent.width
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                            text: "Select a script from the list"
                            visible: !root.selected || !root.selected.id
                        }

                        Column {
                            width: parent.width
                            spacing: 8
                            visible: !!(root.selected && root.selected.id)

                            RowLayout {
                                width: parent.width
                                spacing: 8

                                Text {
                                    Layout.fillWidth: true
                                    color: Theme.primary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    font.bold: true
                                    elide: Text.ElideRight
                                    text: (root.selected.icon || "󰘲") + "  " + (root.selected.name || root.selected.id)
                                }

                                HubButton {
                                    compact: true
                                    label: ""
                                    icon: root.selected.favorite ? "󰅷" : "󰅶"
                                    active: !!root.selected.favorite
                                    onClicked: ScriptRegistry.toggleFavorite(root.selected)
                                }
                            }

                            Text {
                                width: parent.width
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 4
                                wrapMode: Text.Wrap
                                text: root.selected.description || "No description"
                            }

                            Flow {
                                width: parent.width
                                spacing: 5

                                Repeater {
                                    model: Array.isArray(root.selected.tags) ? root.selected.tags : []

                                    HubButton {
                                        required property var modelData
                                        compact: true
                                        label: String(modelData)
                                        onClicked: ScriptRegistry.search = String(modelData)
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                color: Theme.textDim
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 6
                                wrapMode: Text.WrapAnywhere
                                text: "source: " + (root.selected.command || root.selected.path || "unavailable")
                                    + "   category: " + (root.selected.category || "Uncategorized")
                                    + "   launches: " + (root.selected.launches || 0)
                            }

                            Rectangle {
                                width: parent.width
                                visible: root.confirmRun
                                color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.10)
                                radius: 8
                                border.width: 1
                                border.color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.30)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8

                                    Text {
                                        Layout.fillWidth: true
                                        color: Theme.secondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 4
                                        text: "Run " + (root.selected.name || "this script") + "?"
                                    }

                                    HubButton {
                                        compact: true
                                        label: "Run"
                                        accent: true
                                        onClicked: {
                                            root.confirmRun = false;
                                            root.executeSelected();
                                        }
                                    }

                                    HubButton {
                                        compact: true
                                        label: "Cancel"
                                        onClicked: root.confirmRun = false
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                visible: root.confirmForget
                                color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.10)
                                radius: 8
                                border.width: 1
                                border.color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.30)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8

                                    Text {
                                        Layout.fillWidth: true
                                        color: Theme.secondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 4
                                        text: "Delete stored metadata and usage for this script?"
                                    }

                                    HubButton {
                                        compact: true
                                        label: "Delete"
                                        destructive: true
                                        onClicked: {
                                            root.confirmForget = false;
                                            ScriptRegistry.forget(root.selected);
                                            ScriptRegistry.select({});
                                            root.statusMessage = "Stored script data removed";
                                        }
                                    }

                                    HubButton {
                                        compact: true
                                        label: "Cancel"
                                        onClicked: root.confirmForget = false
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 6

                                HubButton {
                                    label: ScriptExecutor.activeFor(root.selected.id) !== null ? "Stop" : "Run"
                                    icon: ScriptExecutor.activeFor(root.selected.id) !== null ? "■" : "▶"
                                    accent: ScriptExecutor.activeFor(root.selected.id) === null
                                    destructive: ScriptExecutor.activeFor(root.selected.id) !== null
                                    onClicked: {
                                        if (ScriptExecutor.activeFor(root.selected.id) !== null) ScriptExecutor.stop(root.selected.id);
                                        else root.runScript(root.selected);
                                    }
                                }

                                HubButton {
                                    compact: true
                                    label: "Edit"
                                    onClicked: {
                                        root.editingNew = false;
                                        root.editing = true;
                                    }
                                }

                                HubButton {
                                    compact: true
                                    label: root.selected.hidden ? "Unhide" : "Hide"
                                    active: !!root.selected.hidden
                                    onClicked: ScriptRegistry.setHidden(root.selected, !root.selected.hidden)
                                }

                                HubButton {
                                    compact: true
                                    label: "Forget"
                                    destructive: true
                                    onClicked: root.confirmForget = true
                                }
                            }

                            ScriptArgumentForm {
                                id: argumentForm
                                width: parent.width
                                script: root.selected
                            }

                            RunningTasks {
                                width: parent.width
                                tasks: ScriptExecutor.tasks
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                color: root.statusMessage.indexOf("failed") >= 0 || root.statusMessage.indexOf("Failed") >= 0 ? Theme.secondary : Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 5
                elide: Text.ElideRight
                text: root.statusMessage || (ScriptRegistry.scripts.length + " scripts discovered  •  " + ScriptRegistry.categories.length + " categories")
            }

            Text {
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 6
                text: Theme.scriptHubDataRoot
            }
        }
    }

    ScriptMetadataEditor {
        anchors.fill: parent
        anchors.margins: 12
        visible: root.editing
        z: 20
        isNew: root.editingNew
        script: root.selected
        onSaved: function (id) {
            root.editing = false;
            root.statusMessage = "Saved metadata for " + id;
            ScriptRegistry.refresh();
        }
        onCancelled: root.editing = false
    }

    Connections {
        target: ScriptRegistry
        function onRefreshFinished() {
            if (!root.statusMessage) root.statusMessage = ScriptRegistry.scripts.length + " scripts discovered";
        }
    }

    Connections {
        target: ScriptExecutor
        function onTaskFinished(task) {
            root.statusMessage = task.name + " " + task.status + " (exit " + task.exitCodeValue + ")";
        }
    }

    function runScript(script) {
        if (!script || !script.id) return;
        if (!script.launchable) {
            root.statusMessage = "Script is not launchable";
            return;
        }
        if (script.confirm) {
            ScriptRegistry.select(script);
            root.confirmRun = true;
            return;
        }
        executeScript(script);
    }

    function executeSelected() {
        executeScript(root.selected);
    }

    function executeScript(script) {
        var values = argumentForm ? argumentForm.collect() : {};
        var error = ScriptExecutor.run(script, values);
        root.statusMessage = error || ("Started " + script.name);
    }

    Keys.onEscapePressed: function (event) {
        if (root.editing) root.editing = false;
        else if (root.confirmRun) root.confirmRun = false;
        else if (root.confirmForget) root.confirmForget = false;
        else root.requestClose();
    }

    onRequestClose: UIState.close("scriptHub")
}
