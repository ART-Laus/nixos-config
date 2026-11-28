import QtQuick
import qs.config
import qs.clipboard.core

Item {
    id: root
    width: parent ? parent.width : 0
    height: 30

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
            width: 4
            height: 4
            radius: 2
            color: ClipboardTheme.emerald
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: section || ""
            color: ClipboardTheme.muted
            font.pixelSize: Theme.fontSize - 3
            font.family: Theme.fontFamily
            font.letterSpacing: 1.2
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
