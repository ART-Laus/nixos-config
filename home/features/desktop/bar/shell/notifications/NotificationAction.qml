import QtQuick
import qs.config

Rectangle {
    id: root

    property string label: ""
    property bool active: false
    property bool danger: false
    property bool subtle: true
    property color accent: danger ? NotificationTokens.danger : NotificationTokens.mint
    signal clicked

    implicitWidth: text.implicitWidth + 16
    implicitHeight: 28
    radius: 9
    border.width: 1
    border.color: active ? NotificationTokens.alpha(accent, 0.45)
        : danger ? NotificationTokens.alpha(accent, 0.28)
        : NotificationTokens.alpha(NotificationTokens.text, 0.08)
    color: active ? NotificationTokens.alpha(accent, 0.16)
        : area.containsMouse ? NotificationTokens.alpha(accent, danger ? 0.14 : 0.10)
        : subtle ? NotificationTokens.alpha(NotificationTokens.text, 0.03) : NotificationTokens.alpha(accent, 0.08)

    Behavior on color { ColorAnimation { duration: NotificationTokens.motionFast } }
    Behavior on border.color { ColorAnimation { duration: NotificationTokens.motionFast } }

    Text {
        id: text
        anchors.centerIn: parent
        text: root.label
        color: root.danger ? (area.containsMouse || root.active ? NotificationTokens.text : NotificationTokens.danger)
            : (root.active || area.containsMouse ? NotificationTokens.text : NotificationTokens.text2)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
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
