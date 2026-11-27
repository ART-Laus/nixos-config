import QtQuick
import qs.config
import qs.scripthub
import qs.notifications

Item {
    id: root

    property var definition: ({})
    property var value: undefined
    signal valueEdited(var value)

    readonly property string type: String(root.definition.type || "text")
    readonly property string name: String(root.definition.name || "")
    readonly property string label: String(root.definition.label || root.name || "Value")
    readonly property string displayValue: root.value === undefined || root.value === null ? "" : String(root.value)
    readonly property bool required: !!root.definition.required

    implicitWidth: parent ? parent.width : 300
    implicitHeight: labelText.implicitHeight + 6 + controlLoader.implicitHeight + 8

    Column {
        anchors.fill: parent
        spacing: 6

        Text {
            id: labelText
            color: root.required ? NotificationTokens.text : NotificationTokens.text2
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 4
            text: root.label + (root.required ? " *" : "")
        }

        Loader {
            id: controlLoader
            width: parent.width
            sourceComponent: {
                if (root.type === "boolean") return booleanControl;
                if (root.type === "select" || root.type === "multiselect") return selectControl;
                return textControl;
            }
        }

        Text {
            width: parent.width
            color: NotificationTokens.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 5
            wrapMode: Text.Wrap
            text: root.definition.description || root.definition.placeholder || ""
            visible: text.length > 0
        }
    }

    Component {
        id: textControl
        HubField {
            width: parent.width
            text: root.displayValue
            placeholder: root.definition.placeholder || ""
            password: root.type === "password"
            numeric: root.type === "number"
            onTextEdited: function (value) { root.valueEdited(value); }
        }
    }

    Component {
        id: booleanControl
        HubButton {
            label: root.value ? "Enabled" : "Disabled"
            icon: root.value ? "󰅵" : "󰅶"
            active: !!root.value
            onClicked: root.valueEdited(!root.value)
        }
    }

    Component {
        id: selectControl
        Flow {
            width: parent.width
            spacing: 6

            Repeater {
                model: Array.isArray(root.definition.options) ? root.definition.options : []

                HubButton {
                    required property var modelData
                    compact: true
                    label: String(modelData)
                    active: root.type === "multiselect"
                        ? Array.isArray(root.value) && root.value.indexOf(String(modelData)) >= 0
                        : root.displayValue === String(modelData)
                    onClicked: {
                        if (root.type !== "multiselect") {
                            root.valueEdited(String(modelData));
                            return;
                        }
                        var values = Array.isArray(root.value) ? root.value.slice() : [];
                        var index = values.indexOf(String(modelData));
                        if (index >= 0) values.splice(index, 1);
                        else values.push(String(modelData));
                        root.valueEdited(values);
                    }
                }
            }
        }
    }
}
