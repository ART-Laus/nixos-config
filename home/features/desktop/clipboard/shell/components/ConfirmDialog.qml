import QtQuick
import qs.config
import qs.clipboard.core

Rectangle {
    id: root

    property string title: ""
    property string message: ""
    property string confirmLabel: "Confirm"
    signal confirmed()
    signal cancelled()

    anchors.fill: parent
    color: Qt.rgba(ClipboardTheme.canvas.r, ClipboardTheme.canvas.g, ClipboardTheme.canvas.b, 0.82)
    z: 20

    Rectangle {
        z: 1
        width: 400
        height: 168
        anchors.centerIn: parent
        radius: ClipboardTheme.radius
        color: ClipboardTheme.surface
        border.color: ClipboardTheme.border
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                text: root.title
                color: ClipboardTheme.text
                font.pixelSize: Theme.fontSize + 2
                font.bold: true
                font.family: Theme.fontFamily
            }

            Text {
                text: root.message
                color: ClipboardTheme.textDim
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Item { height: 8 }

            Row {
                anchors.right: parent.right
                spacing: 8

                Rectangle {
                    width: 92
                    height: 32
                    radius: 10
                    color: Qt.rgba(ClipboardTheme.canvas.r, ClipboardTheme.canvas.g, ClipboardTheme.canvas.b, 0.8)
                    border.color: ClipboardTheme.border
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: ClipboardTheme.textDim
                        font.pixelSize: Theme.fontSize - 1
                        font.family: Theme.fontFamily
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancelled()
                    }
                }

                Rectangle {
                    width: 104
                    height: 32
                    radius: 10
                    color: Qt.rgba(ClipboardTheme.emerald.r, ClipboardTheme.emerald.g, ClipboardTheme.emerald.b, 0.22)
                    border.color: Qt.rgba(ClipboardTheme.emerald.r, ClipboardTheme.emerald.g, ClipboardTheme.emerald.b, 0.5)
                    Text {
                        anchors.centerIn: parent
                        text: root.confirmLabel
                        color: ClipboardTheme.accent
                        font.pixelSize: Theme.fontSize - 1
                        font.family: Theme.fontFamily
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.confirmed()
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelled()
    }
}
