import QtQuick
import qs.config
import qs.clipboard.core

Rectangle {
    id: root

    property var entry: null
    signal back()
    signal copy(int id)
    signal keyEvent(var event)

    anchors.fill: parent
    color: Qt.rgba(ClipboardTheme.canvas.r, ClipboardTheme.canvas.g, ClipboardTheme.canvas.b, 0.98)
    radius: ClipboardTheme.radius
    z: 15

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Row {
            anchors.right: parent.right
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Entry #" + (root.entry ? root.entry.id : 0)
                color: ClipboardTheme.textDim
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
            }

            Rectangle {
                width: 72
                height: 30
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(ClipboardTheme.canvas.r, ClipboardTheme.canvas.g, ClipboardTheme.canvas.b, 0.7)
                border.color: ClipboardTheme.border
                Text {
                    anchors.centerIn: parent
                    text: "← Back"
                    color: ClipboardTheme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.back()
                }
            }

            Rectangle {
                id: copyButton
                width: 84
                height: 30
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(ClipboardTheme.emerald.r, ClipboardTheme.emerald.g, ClipboardTheme.emerald.b, 0.22)
                border.color: Qt.rgba(ClipboardTheme.accent.r, ClipboardTheme.accent.g, ClipboardTheme.accent.b, 0.4)
                Text {
                    anchors.centerIn: parent
                    text: "Copy"
                    color: ClipboardTheme.accent
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.copy(Number(root.entry ? root.entry.id : 0))
                }
            }
        }

        Flickable {
            width: parent.width
            height: parent.height - 46
            contentWidth: width
            contentHeight: root.entry && root.entry.kind === "image"
                ? image.visible ? image.height + 20 : 60
                : Math.max(textArea.implicitHeight + 20, 60)
            clip: true

            TextEdit {
                id: textArea
                visible: !root.entry || root.entry.kind !== "image"
                width: parent.width
                readOnly: true
                selectByMouse: true
                selectByKeyboard: true
                wrapMode: TextEdit.WrapAnywhere
                color: ClipboardTheme.text
                font.pixelSize: Theme.fontSize - 1
                font.family: ClipboardTheme.monoFont
                text: root.entry ? String(root.entry.content || "") : ""
                Keys.onPressed: function (event) { root.keyEvent(event); }
            }

            Image {
                id: image
                visible: !!root.entry && root.entry.kind === "image" && !!root.entry.imagePath
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 420
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                source: root.entry && root.entry.imagePath ? root.entry.imagePath : ""
            }
        }
    }
}
