import QtQuick
import qs.config
import qs.scripthub
import qs.notifications

Item {
    id: root

    property var script: ({})
    property var values: ({})
    signal valuesEdited()

    implicitWidth: parent ? parent.width : 300
    implicitHeight: column.implicitHeight

    Column {
        id: column
        width: parent.width
        spacing: 8

        Rectangle {
            width: parent.width
            height: 1
            color: NotificationTokens.divider
        }

        Text {
            width: parent.width
            color: NotificationTokens.mint
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 5
            font.bold: true
            text: "ARGUMENTS"
            visible: root.hasArguments
        }

        Repeater {
            model: Array.isArray(root.script.arguments) ? root.script.arguments : []

            ArgumentRow {
                required property var modelData
                width: parent.width
                definition: modelData
                value: root.values[modelData.name]
                onValueEdited: function (value) { root.setArg(modelData.name, value); }
            }
        }

        Text {
            width: parent.width
            color: NotificationTokens.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 5
            text: "No arguments required"
            visible: !root.hasArguments
        }
    }

    readonly property bool hasArguments: Array.isArray(root.script.arguments) && root.script.arguments.length > 0

    function defaultValue(definition) {
        if (!definition) return "";
        if (definition.type === "boolean") return !!definition.default;
        if (definition.type === "multiselect") return Array.isArray(definition.default) ? definition.default.slice() : [];
        if (definition.default === undefined || definition.default === null) return "";
        return definition.default;
    }

    function reset() {
        var next = {};
        var definitions = Array.isArray(root.script.arguments) ? root.script.arguments : [];
        for (var i = 0; i < definitions.length; i++) {
            var definition = definitions[i];
            if (!definition || !definition.name) continue;
            next[definition.name] = root.defaultValue(definition);
        }
        root.values = next;
        root.valuesEdited();
    }

    function setArg(name, value) {
        var next = JSON.parse(JSON.stringify(root.values));
        next[name] = value;
        root.values = next;
        root.valuesEdited();
    }

    function collect() {
        return JSON.parse(JSON.stringify(root.values));
    }

    Component.onCompleted: root.reset()
    onScriptChanged: root.reset()
}
