import QtQuick
import qs.components
import qs.config
import qs.scripthub
import qs.notifications

Pill {
    id: root

    readonly property int activeTasks: ScriptExecutor.tasks.filter(function (task) { return task.endedAt === 0; }).length
    tooltip: activeTasks > 0 ? "Script Hub  " + activeTasks + " running" : "Script Hub"

    active: UIState.activePopup === "scriptHub"

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: root.active ? NotificationTokens.mint : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: "󰘲"
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        color: root.active ? NotificationTokens.text : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        text: "Scripts"
    }

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
        width: 6
        height: 6
        radius: 3
        color: NotificationTokens.mint
        visible: root.activeTasks > 0
    }

    onClicked: UIState.open("scriptHub")
}
