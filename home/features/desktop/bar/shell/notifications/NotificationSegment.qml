import QtQuick
import qs.config

Rectangle {
    id: root

    property string label: ""
    property bool active: false
    property color accent: NotificationTokens.mint
    signal clicked

    implicitWidth: text.implicitWidth + 18
    implicitHeight: 30
    radius: NotificationTokens.radiusControl
    border.width: 1
    border.color: active ? NotificationTokens.alpha(accent, 0.45) : NotificationTokens.border
    color: active
        ? NotificationTokens.alpha(accent, 0.16)
        : (area.containsMouse ? NotificationTokens.alpha(NotificationTokens.text, 0.07) : NotificationTokens.alpha(NotificationTokens.text, 0.03))

    Behavior on color { ColorAnimation { duration: NotificationTokens.motionFast } }
    Behavior on border.color { ColorAnimation { duration: NotificationTokens.motionFast } }

    Text {
        id: text
        anchors.centerIn: parent
        text: root.label
        color: root.active ? NotificationTokens.text : (area.containsMouse ? NotificationTokens.text : NotificationTokens.text2)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.weight: root.active ? Font.DemiBold : Font.Medium
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
