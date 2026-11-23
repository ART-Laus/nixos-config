import QtQuick
import qs.config

Rectangle {
    id: root

    property string label: ""
    property bool active: false
    property bool accent: false
    signal clicked

    implicitWidth: text.implicitWidth + 20
    implicitHeight: 28
    radius: 8
    color: active || area.containsMouse
        ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)
        : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.06)
    Text {
        id: text
        anchors.centerIn: parent
        color: active || accent ? Theme.primary : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        text: root.label
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
