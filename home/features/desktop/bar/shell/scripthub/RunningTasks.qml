import QtQuick
import qs.config
import qs.scripthub
import qs.notifications

Item {
    id: root

    property var tasks: []
    property bool expanded: false

    implicitWidth: parent ? parent.width : 300
    implicitHeight: column.implicitHeight

    function colorFor(status) {
        if (status === "success" || status === "detached") return NotificationTokens.emerald;
        if (status === "failed" || status === "timeout") return NotificationTokens.danger;
        if (status === "running" || status === "starting" || status === "stopping") return NotificationTokens.mint;
        return NotificationTokens.muted;
    }

    function tail(text) {
        var value = String(text || "").trim();
        return value.length > 1600 ? value.slice(value.length - 1600) : value;
    }

    Column {
        id: column
        width: parent.width
        spacing: 7

        Rectangle {
            width: parent.width
            height: 1
            color: NotificationTokens.divider
        }

        Row {
            width: parent.width

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: NotificationTokens.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 5
                font.bold: true
                text: "RUNNING TASKS (" + root.tasks.length + ")"
            }

            Item { width: 8; height: 1 }

            HubButton {
                anchors.verticalCenter: parent.verticalCenter
                compact: true
                label: root.expanded ? "Collapse" : "Expand"
                onClicked: root.expanded = !root.expanded
            }
        }

        Text {
            width: parent.width
            color: NotificationTokens.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 5
            text: "No active tasks"
            visible: root.tasks.length === 0
        }

        Repeater {
            model: root.tasks

            Rectangle {
                required property var modelData
                width: parent.width
                implicitHeight: taskColumn.implicitHeight + 12
                radius: NotificationTokens.radiusControl
                color: NotificationTokens.alpha(NotificationTokens.canvas, 0.26)
                border.width: 1
                border.color: NotificationTokens.divider

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 1
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                    width: 2
                    radius: 1
                    color: root.colorFor(modelData.status)
                }

                Column {
                    id: taskColumn
                    anchors.fill: parent
                    anchors.margins: 7
                    anchors.leftMargin: 11
                    spacing: 3

                    Row {
                        width: parent.width

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 76
                            color: root.colorFor(modelData.status)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                            elide: Text.ElideRight
                            text: "● " + modelData.name + "  [" + modelData.status + "]"
                        }

                        HubButton {
                            anchors.verticalCenter: parent.verticalCenter
                            compact: true
                            label: modelData.endedAt === 0 ? "Stop" : "Clear"
                            destructive: modelData.endedAt === 0
                            onClicked: modelData.endedAt === 0 ? ScriptExecutor.stop(modelData.id) : ScriptExecutor.clearFinished()
                        }
                    }

                    Text {
                        width: parent.width
                        color: NotificationTokens.text2
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 6
                        elide: Text.ElideRight
                        text: modelData.commandDisplay
                    }

                    Text {
                        width: parent.width
                        visible: root.expanded && (modelData.status === "failed" || modelData.status === "timeout" || modelData.stdoutText.length > 0 || modelData.stderrText.length > 0)
                        color: modelData.stderrText.length > 0 ? NotificationTokens.danger : NotificationTokens.text2
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 6
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: root.expanded ? 16 : 2
                        elide: Text.ElideRight
                        text: root.tail(modelData.stderrText || modelData.stdoutText)
                    }
                }
            }
        }
    }
}
