import QtQuick
import qs.config

Rectangle {
    id: root
    property string placeholder: ""
    property alias text: input.text
    readonly property bool focused: input.activeFocus
    signal accepted(string text)
    signal cleared()
    signal escapePressed()
    signal navigationRequested(int key)

    function forceFocus() {
        input.forceActiveFocus();
    }

    implicitHeight: 36
    radius: AppSettings.cardRadius
    color: Theme.pill
    border.color: input.activeFocus ? Theme.primary : Theme.pill
    border.width: 1

    Behavior on border.color {
        ColorAnimation { duration: AppSettings.transitionFast }
    }

    Text {
        id: prefix
        text: "⌕"
        color: Theme.textDim
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    TextInput {
        id: input
        anchors.left: prefix.right
        anchors.leftMargin: 8
        anchors.right: clearBtn.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.text
        selectionColor: Theme.primaryDim
        selectedTextColor: Theme.text
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
        verticalAlignment: TextInput.AlignVCenter
        wrapMode: TextInput.NoWrap
        Keys.onReturnPressed: root.accepted(text)
        Keys.onEscapePressed: root.escapePressed()
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_PageUp || event.key === Qt.Key_PageDown) {
                root.navigationRequested(event.key);
                event.accepted = true;
            }
        }
    }

    Text {
        id: placeholderText
        visible: input.text.length === 0
        anchors.left: input.left
        anchors.verticalCenter: input.verticalCenter
        text: root.placeholder
        color: Theme.textDim
        font.pixelSize: Theme.fontSize
        font.family: Theme.fontFamily
    }

    Text {
        id: clearBtn
        visible: input.text.length > 0
        text: "×"
        color: clearMouse.containsMouse ? Theme.text : Theme.textDim
        font.pixelSize: Theme.fontSize + 2
        font.family: Theme.fontFamily
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color {
            ColorAnimation { duration: AppSettings.transitionFast }
        }

        MouseArea {
            id: clearMouse
            anchors.fill: parent
            anchors.margins: -4
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
