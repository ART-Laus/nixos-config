import QtQuick
import qs.config
import qs.scripthub
import qs.notifications

Rectangle {
    id: root

    property var script: ({})
    property bool isNew: false
    property var draft: ({})
    signal saved(string id)
    signal cancelled()

    readonly property var argumentTypes: ["text", "number", "boolean", "select", "multiselect", "file", "files", "directory", "password"]

    color: NotificationTokens.alpha(NotificationTokens.canvas, 0.94)
    radius: NotificationTokens.radiusPanel
    border.width: 1
    border.color: NotificationTokens.alpha(NotificationTokens.mint, 0.32)

    function normalizeId(value) {
        return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
    }

    function load() {
        if (root.isNew) {
            root.draft = {
                name: "",
                description: "",
                category: "Custom",
                icon: "󰘲",
                tags: [],
                path: "",
                command: "",
                hidden: false,
                confirm: false,
                execution: { mode: "normal", timeout: 0, allowMultipleInstances: false },
                arguments: []
            };
        } else {
            var source = ScriptRegistry.effectiveMeta(root.script);
            root.draft = {
                name: source.name || "",
                description: source.description || "",
                category: source.category || "Uncategorized",
                icon: source.icon || "󰘲",
                tags: Array.isArray(source.tags) ? source.tags.slice() : [],
                path: source.path || source.sourcePath || "",
                command: source.command || "",
                hidden: !!source.hidden,
                confirm: !!source.confirm,
                execution: {
                    mode: source.executionMode || "normal",
                    timeout: Number(source.timeout || 0),
                    allowMultipleInstances: !!source.allowMultipleInstances
                },
                arguments: Array.isArray(source.arguments) ? JSON.parse(JSON.stringify(source.arguments)) : []
            };
        }
    }

    function update(key, value) {
        var next = JSON.parse(JSON.stringify(root.draft));
        next[key] = value;
        root.draft = next;
    }

    function updateExecution(key, value) {
        var next = JSON.parse(JSON.stringify(root.draft));
        if (!next.execution || typeof next.execution !== "object") next.execution = {};
        next.execution[key] = value;
        root.draft = next;
    }

    function updateArg(index, key, value) {
        var next = JSON.parse(JSON.stringify(root.draft));
        if (!Array.isArray(next.arguments)) next.arguments = [];
        if (!next.arguments[index]) next.arguments[index] = {};
        next.arguments[index][key] = value;
        root.draft = next;
    }

    function addArg() {
        var next = JSON.parse(JSON.stringify(root.draft));
        if (!Array.isArray(next.arguments)) next.arguments = [];
        next.arguments.push({ name: "arg" + (next.arguments.length + 1), label: "Argument", type: "text", required: false, default: "" });
        root.draft = next;
    }

    function removeArg(index) {
        var next = JSON.parse(JSON.stringify(root.draft));
        if (!Array.isArray(next.arguments)) return;
        next.arguments.splice(index, 1);
        root.draft = next;
    }

    function save() {
        var id = root.isNew ? root.normalizeId(root.draft.command || root.draft.path || root.draft.name) : root.script.id;
        if (!id) return;
        var draft = JSON.parse(JSON.stringify(root.draft));
        draft.tags = String(root.draft.tags || "").split(",").map(function (tag) { return tag.trim(); }).filter(function (tag) { return tag.length > 0; });
        for (var i = 0; i < draft.arguments.length; i++) {
            var arg = draft.arguments[i];
            if (arg.type === "select" || arg.type === "multiselect") {
                arg.options = String(arg.options || "").split(",").map(function (option) { return option.trim(); }).filter(function (option) { return option.length > 0; });
            } else {
                delete arg.options;
            }
            if (arg.type === "password") delete arg.default;
        }
        ScriptRegistry.saveMetadata({ id: id, path: root.draft.path, command: root.draft.command }, draft);
        root.saved(id);
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 10
        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true

        Column {
            id: content
            width: parent.width
            spacing: 7

            Row {
                width: parent.width
                spacing: 7

                Rectangle {
                    width: 3
                    height: parent.implicitHeight
                    radius: 2
                    color: NotificationTokens.mint
                }

                Text {
                    color: NotificationTokens.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    font.bold: true
                    text: root.isNew ? "ADD SCRIPT" : "EDIT METADATA"
                }
            }

            Text {
                width: parent.width
                color: NotificationTokens.text2
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 5
                wrapMode: Text.Wrap
                text: "Path or command must be executable. Metadata is stored locally and never executes scripts during discovery."
            }

            HubField {
                width: parent.width
                placeholder: "Script id"
                visible: root.isNew
                text: root.normalizeId(root.draft.command || root.draft.path || root.draft.name)
                readOnly: true
            }

            HubField {
                width: parent.width
                placeholder: "Display name"
                text: root.draft.name || ""
                onTextEdited: function (value) { root.update("name", value); }
            }

            HubField {
                width: parent.width
                placeholder: "Description"
                text: root.draft.description || ""
                onTextEdited: function (value) { root.update("description", value); }
            }

            Row {
                width: parent.width
                spacing: 6

                HubField {
                    width: parent.width / 2 - 3
                    placeholder: "Category"
                    text: root.draft.category || ""
                    onTextEdited: function (value) { root.update("category", value); }
                }

                HubField {
                    width: parent.width / 2 - 3
                    placeholder: "Icon"
                    text: root.draft.icon || ""
                    onTextEdited: function (value) { root.update("icon", value); }
                }
            }

            HubField {
                width: parent.width
                placeholder: "Tags, comma separated"
                text: Array.isArray(root.draft.tags) ? root.draft.tags.join(", ") : ""
                onTextEdited: function (value) { root.update("tags", value); }
            }

            HubField {
                width: parent.width
                placeholder: "Absolute script path"
                text: root.draft.path || ""
                onTextEdited: function (value) { root.update("path", value); }
            }

            HubField {
                width: parent.width
                placeholder: "Command name from PATH"
                text: root.draft.command || ""
                onTextEdited: function (value) { root.update("command", value); }
            }

            Text {
                color: NotificationTokens.lavenderSoft
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 5
                font.bold: true
                text: "EXECUTION"
            }

            Flow {
                width: parent.width
                spacing: 6

                Repeater {
                    model: ["normal", "long", "detached"]

                    HubButton {
                        required property var modelData
                        compact: true
                        label: String(modelData)
                        active: root.draft.execution && root.draft.execution.mode === modelData
                        onClicked: root.updateExecution("mode", modelData)
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 6

                HubField {
                    width: parent.width / 2 - 3
                    placeholder: "Timeout seconds"
                    numeric: true
                    text: root.draft.execution ? String(root.draft.execution.timeout || 0) : "0"
                    onTextEdited: function (value) { root.updateExecution("timeout", Number(value || 0)); }
                }

                Column {
                    width: parent.width / 2 - 3
                    spacing: 6

                    HubButton {
                        compact: true
                        label: "Confirm before run"
                        active: !!root.draft.confirm
                        onClicked: root.update("confirm", !root.draft.confirm)
                    }

                    HubButton {
                        compact: true
                        label: "Hidden from list"
                        active: !!root.draft.hidden
                        onClicked: root.update("hidden", !root.draft.hidden)
                    }
                }
            }

            Row {
                width: parent.width

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: NotificationTokens.lavenderSoft
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 5
                    font.bold: true
                    text: "ARGUMENTS"
                }

                Item { width: 10; height: 1 }

                HubButton {
                    anchors.verticalCenter: parent.verticalCenter
                    compact: true
                    label: "Add"
                    onClicked: root.addArg()
                }
            }

            Repeater {
                model: Array.isArray(root.draft.arguments) ? root.draft.arguments.length : 0

                Rectangle {
                    required property int index
                    width: parent.width
                    implicitHeight: argColumn.implicitHeight + 10
                    radius: NotificationTokens.radiusControl
                    color: NotificationTokens.alpha(NotificationTokens.canvas, 0.28)
                    border.width: 1
                    border.color: NotificationTokens.divider

                    Column {
                        id: argColumn
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 5

                        Row {
                            width: parent.width
                            spacing: 5

                            HubField {
                                width: parent.width / 2 - 3
                                placeholder: "name"
                                text: root.draft.arguments[index].name || ""
                                onTextEdited: function (value) { root.updateArg(index, "name", value); }
                            }

                            HubField {
                                width: parent.width / 2 - 3
                                placeholder: "label"
                                text: root.draft.arguments[index].label || ""
                                onTextEdited: function (value) { root.updateArg(index, "label", value); }
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: 5

                            Repeater {
                                model: root.argumentTypes

                                HubButton {
                                    required property var modelData
                                    compact: true
                                    label: String(modelData)
                                    active: root.draft.arguments[index].type === modelData
                                    onClicked: root.updateArg(index, "type", modelData)
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 5

                            HubButton {
                                compact: true
                                label: "required"
                                active: !!root.draft.arguments[index].required
                                onClicked: root.updateArg(index, "required", !root.draft.arguments[index].required)
                            }

                            HubButton {
                                compact: true
                                label: "Remove"
                                destructive: true
                                onClicked: root.removeArg(index)
                            }
                        }

                        HubField {
                            width: parent.width
                            placeholder: "Default value or comma separated options"
                            text: root.draft.arguments[index].type === "select" || root.draft.arguments[index].type === "multiselect"
                                ? Array.isArray(root.draft.arguments[index].options) ? root.draft.arguments[index].options.join(", ") : ""
                                : String(root.draft.arguments[index].default || "")
                            onTextEdited: function (value) {
                                if (root.draft.arguments[index].type === "select" || root.draft.arguments[index].type === "multiselect") {
                                    root.updateArg(index, "options", value.split(",").map(function (entry) { return entry.trim(); }).filter(function (entry) { return entry.length > 0; }));
                                } else {
                                    root.updateArg(index, "default", value);
                                }
                            }
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 6

                HubButton {
                    label: "Save"
                    accent: true
                    onClicked: root.save()
                }

                HubButton {
                    label: "Cancel"
                    onClicked: root.cancelled()
                }
            }
        }
    }

    Component.onCompleted: root.load()
    onScriptChanged: if (!root.isNew) root.load()
    onIsNewChanged: root.load()
}
