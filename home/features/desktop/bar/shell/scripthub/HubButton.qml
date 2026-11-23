import QtQuick
import qs.config

Rectangle {
    id: root

    property string label: ""
    property string icon: ""
    property bool accent: false
    property bool active: false
    property bool destructive: false
    property bool compact: false
    signal clicked()

    implicitWidth: (icon.length > 0 ? iconText.implicitWidth + 6 : 0) + labelText.implicitWidth + (compact ? 14 : 22)
    implicitHeight: compact ? 24 : 30
    radius: 8
    color: area.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)
        : active ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
        : destructive ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.08)
        : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.04)
    border.width: 1
    border.color: active || accent ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.45)
        : destructive ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.32)
        : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.10)

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: iconText
            visible: text.length > 0
            anchors.verticalCenter: parent.verticalCenter
            color: root.destructive ? Theme.secondary : Theme.primary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            text: root.icon
        }

        Text {
            id: labelText
            anchors.verticalCenter: parent.verticalCenter
            color: root.destructive ? Theme.secondary : root.accent || root.active ? Theme.primary : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - (root.compact ? 4 : 3)
            text: root.label
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Behavior on color { ColorAnimation { duration: Settings.animationDuration } }
}
