import QtQuick
import qs.config
import qs.clipboard.core

Rectangle {
    id: root

    property string label: ""
    property string glyph: "◇"
    property int count: 0
    property bool active: false
    property color activeColor: ClipboardTheme.accent
    signal clicked()

    implicitHeight: 30
    implicitWidth: row.implicitWidth + 18
    radius: 15
    color: active ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.14) : "transparent"
    border.color: active ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.35) : "transparent"
    border.width: 1

    Behavior on color {
        ColorAnimation { duration: ClipboardTheme.fast }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.glyph
            color: root.active ? activeColor : ClipboardTheme.muted
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.fontFamily
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.label
            color: root.active ? ClipboardTheme.text : ClipboardTheme.textDim
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.fontFamily
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: root.count > 0
            text: root.count > 999 ? "999+" : String(root.count)
            color: root.active ? activeColor : ClipboardTheme.muted
            font.pixelSize: Theme.fontSize - 3
            font.family: Theme.fontFamily
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
