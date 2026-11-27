import QtQuick
import qs.config
import qs.scripthub
import qs.notifications

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
    implicitHeight: compact ? 25 : 31
    radius: NotificationTokens.radiusControl

    readonly property color accentColor: root.destructive ? NotificationTokens.danger
        : root.active || root.accent ? NotificationTokens.mint : NotificationTokens.text2

    color: area.containsMouse ? NotificationTokens.alpha(accentColor, 0.14)
        : root.active ? NotificationTokens.alpha(NotificationTokens.mint, 0.11)
        : root.accent ? NotificationTokens.alpha(NotificationTokens.mint, 0.08)
        : root.destructive ? NotificationTokens.alpha(NotificationTokens.danger, 0.07)
        : NotificationTokens.alpha(NotificationTokens.text, 0.035)
    border.width: 1
    border.color: area.containsMouse || root.active || root.accent
        ? NotificationTokens.alpha(accentColor, 0.42)
        : root.destructive ? NotificationTokens.alpha(NotificationTokens.danger, 0.28)
        : NotificationTokens.divider

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: iconText
            visible: text.length > 0
            anchors.verticalCenter: parent.verticalCenter
            color: root.accentColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            text: root.icon
        }

        Text {
            id: labelText
            anchors.verticalCenter: parent.verticalCenter
            color: root.active || root.accent || root.destructive ? root.accentColor : NotificationTokens.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - (root.compact ? 4 : 3)
            font.weight: root.active || root.accent ? Font.Medium : Font.Normal
            text: root.label
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Behavior on color { ColorAnimation { duration: NotificationTokens.motionFast } }
    Behavior on border.color { ColorAnimation { duration: NotificationTokens.motionFast } }
}
