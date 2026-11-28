import QtQuick
import qs.config
import qs.clipboard.core

Rectangle {
    id: root

    property string placeholder: ""
    property alias text: input.text
    readonly property bool focused: input.activeFocus
    signal keyEvent(var event)
    signal cleared()

    function forceFocus() {
        input.forceActiveFocus();
    }

    implicitHeight: 38
    radius: ClipboardTheme.cardRadius
    color: Qt.rgba(ClipboardTheme.canvas.r, ClipboardTheme.canvas.g, ClipboardTheme.canvas.b, 0.72)
    border.color: input.activeFocus ? ClipboardTheme.accent : ClipboardTheme.border
    border.width: 1

    Behavior on border.color {
        ColorAnimation { duration: ClipboardTheme.fast }
    }

    Text {
        id: prefix
        text: "⌕"
        color: input.activeFocus ? ClipboardTheme.accent : ClipboardTheme.muted
        font.pixelSize: Theme.fontSize + 2
        font.family: Theme.fontFamily
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
            ColorAnimation { duration: ClipboardTheme.fast }
        }
    }

    TextInput {
        id: input
        anchors.left: prefix.right
        anchors.leftMargin: 10
        anchors.right: clearButton.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        color: ClipboardTheme.text
        selectionColor: ClipboardTheme.emerald
        selectedTextColor: ClipboardTheme.canvas
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
        verticalAlignment: TextInput.AlignVCenter
        wrapMode: TextInput.NoWrap

        Keys.onPressed: function (event) { root.keyEvent(event); }
    }

    Text {
        id: placeholderText
        visible: input.text.length === 0
        anchors.left: input.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholder
        color: ClipboardTheme.muted
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
    }

    Text {
        id: clearButton
        visible: input.text.length > 0
        text: "×"
        color: clearMouse.containsMouse ? ClipboardTheme.accent : ClipboardTheme.muted
        font.pixelSize: Theme.fontSize + 3
        font.family: Theme.fontFamily
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
            ColorAnimation { duration: ClipboardTheme.fast }
        }

        MouseArea {
            id: clearMouse
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                input.text = "";
                root.cleared();
                input.forceActiveFocus();
            }
        }
    }
}
