import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.scripthub
import qs.notifications

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
        color: NotificationTokens.panel
        radius: NotificationTokens.radiusPanel
        border.width: 1
        border.color: NotificationTokens.borderStrong

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.width: 1
            border.color: NotificationTokens.alpha(NotificationTokens.text, 0.025)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: NotificationTokens.pad
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 3
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter
                radius: 2
                color: NotificationTokens.mint
                opacity: 0.8
            }

            Column {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    color: NotificationTokens.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                    text: "SCRIPT HUB"
                }

                Text {
                    color: NotificationTokens.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 6
                    text: "local commands  /  verified metadata"
                }
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

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: NotificationTokens.divider
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
                icon: "󰅷"
                active: ScriptRegistry.sortMode === "favorites"
                onClicked: ScriptRegistry.sortMode = "favorites"
            }

            HubButton {
                compact: true
                label: "Recent"
                icon: "󰆵"
                active: ScriptRegistry.sortMode === "recent"
                onClicked: ScriptRegistry.sortMode = "recent"
            }

            HubButton {
                compact: true
                label: "Name"
                icon: "󰅢"
                active: ScriptRegistry.sortMode === "name"
                onClicked: ScriptRegistry.sortMode = "name"
            }

            HubButton {
                compact: true
                label: "Hidden"
                icon: "󰈺"
                active: ScriptRegistry.showHidden
                onClicked: ScriptRegistry.showHidden = !ScriptRegistry.showHidden
            }
        }

        Flickable {
            id: categoryStrip
            Layout.fillWidth: true
            Layout.preferredHeight: 27
            contentWidth: categoryRow.implicitWidth
            contentHeight: 27
            clip: true
            flickableDirection: Flickable.HorizontalFlick

            Row {
                id: categoryRow
                height: 27
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
            spacing: 9

            Rectangle {
                Layout.preferredWidth: 246
                Layout.fillHeight: true
                radius: NotificationTokens.radiusCard
                color: NotificationTokens.alpha(NotificationTokens.canvas, 0.34)
                border.width: 1
                border.color: NotificationTokens.border

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

                        Text {
                            width: parent.width
                            color: NotificationTokens.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 6
                            text: "REGISTRY  /  " + ScriptRegistry.filteredScripts.length
                        }

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
                            color: NotificationTokens.text2
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
                radius: NotificationTokens.radiusCard
                color: NotificationTokens.alpha(NotificationTokens.canvas, 0.34)
                border.width: 1
                border.color: NotificationTokens.border

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 10
                    contentWidth: width
                    contentHeight: details.implicitHeight
                    clip: true

                    Column {
                        id: details
                        width: parent.width
                        spacing: 9

                        Text {
                            width: parent.width
                            color: NotificationTokens.text2
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                            text: "Select a script from the list"
                            visible: !root.selected || !root.selected.id
                        }

                        Column {
                            width: parent.width
                            spacing: 9
                            visible: !!(root.selected && root.selected.id)

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: NotificationTokens.divider
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    radius: NotificationTokens.radiusControl
                                    color: NotificationTokens.alpha(NotificationTokens.mint, 0.12)
                                    border.width: 1
                                    border.color: NotificationTokens.alpha(NotificationTokens.mint, 0.28)

                                    Text {
                                        anchors.centerIn: parent
                                        color: NotificationTokens.mint
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                        text: root.selected.icon || "󰘲"
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    color: NotificationTokens.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    font.bold: true
                                    elide: Text.ElideRight
                                    text: root.selected.name || root.selected.id
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
                                color: NotificationTokens.text2
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

                            Rectangle {
                                width: parent.width
                                radius: NotificationTokens.radiusControl
                                color: NotificationTokens.alpha(NotificationTokens.lavender, 0.07)
                                border.width: 1
                                border.color: NotificationTokens.alpha(NotificationTokens.lavender, 0.22)

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 7
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        color: NotificationTokens.lavenderSoft
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 6
                                        wrapMode: Text.WrapAnywhere
                                        text: "source: " + (root.selected.command || root.selected.path || "unavailable")
                                    }

                                    Text {
                                        width: parent.width
                                        color: NotificationTokens.text2
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 6
                                        wrapMode: Text.WrapAnywhere
                                        text: "category: " + (root.selected.category || "Uncategorized") + "   launches: " + (root.selected.launches || 0)
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                visible: root.confirmRun
                                radius: NotificationTokens.radiusControl
                                color: NotificationTokens.alpha(NotificationTokens.warning, 0.09)
                                border.width: 1
                                border.color: NotificationTokens.alpha(NotificationTokens.warning, 0.36)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        color: NotificationTokens.warning
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
                                radius: NotificationTokens.radiusControl
                                color: NotificationTokens.alpha(NotificationTokens.danger, 0.08)
                                border.width: 1
                                border.color: NotificationTokens.alpha(NotificationTokens.danger, 0.34)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        color: NotificationTokens.danger
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

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: NotificationTokens.divider
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 6
                Layout.preferredHeight: 6
                radius: 3
                color: root.statusMessage.indexOf("failed") >= 0 || root.statusMessage.indexOf("Failed") >= 0
                    ? NotificationTokens.danger : NotificationTokens.emerald
                opacity: 0.85
            }

            Text {
                Layout.fillWidth: true
                color: NotificationTokens.text2
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 5
                elide: Text.ElideRight
                text: root.statusMessage || (ScriptRegistry.scripts.length + " scripts discovered  •  " + ScriptRegistry.categories.length + " categories")
            }

            Text {
                color: NotificationTokens.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 6
                text: Theme.scriptHubDataRoot
            }
        }
    }

    ScriptMetadataEditor {
        anchors.fill: parent
        anchors.margins: NotificationTokens.pad
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
