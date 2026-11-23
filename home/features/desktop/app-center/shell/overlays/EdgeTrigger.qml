import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root

    property var targetScreen: null
    property var modelData: null

    screen: targetScreen
    implicitWidth: AppSettings.edgeTriggerWidth
    implicitHeight: AppSettings.edgeTriggerHeight
    visible: true
    color: "transparent"
    focusable: false
    aboveWindows: true
    exclusiveZone: 0
    surfaceFormat.opaque: false
    anchors.left: true
    anchors.bottom: true
    margins.left: targetScreen ? Math.max(0, Math.floor((targetScreen.width - AppSettings.edgeTriggerWidth) / 2)) : 0
    margins.bottom: 0

    mask: Region { item: surface }

    Rectangle {
        id: surface
        anchors.fill: parent
        color: "transparent"

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            radius: 1
            color: Theme.primary
            opacity: area.containsMouse ? 0.75 : 0.12

            Behavior on opacity {
                NumberAnimation { duration: AppSettings.transitionFast }
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: AppState.setHover("trigger", true, targetScreen)
            onExited: AppState.setHover("trigger", false, targetScreen)
        }
    }
}
