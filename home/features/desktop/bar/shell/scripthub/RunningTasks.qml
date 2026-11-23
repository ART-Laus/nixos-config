import QtQuick
import qs.config
import qs.scripthub

Item {
    id: root

    property var tasks: []
    property bool expanded: false

    implicitWidth: parent ? parent.width : 300
    implicitHeight: column.implicitHeight

    function colorFor(status) {
        if (status === "success" || status === "detached") return Theme.primary;
        if (status === "failed" || status === "timeout") return Theme.secondary;
        if (status === "running" || status === "starting" || status === "stopping") return Theme.secondary;
        return Theme.textDim;
    }

    function tail(text) {
        var value = String(text || "").trim();
        return value.length > 1600 ? value.slice(value.length - 1600) : value;
    }

    Column {
        id: column
        width: parent.width
        spacing: 6

        Row {
            width: parent.width

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.primary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
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
            color: Theme.textDim
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
                radius: 8
                color: Qt.rgba(0, 0, 0, 0.18)
                border.width: 1
                border.color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.07)

                Column {
                    id: taskColumn
                    anchors.fill: parent
                    anchors.margins: 6
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
                        color: Theme.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 6
                        elide: Text.ElideRight
                        text: modelData.commandDisplay
                    }

                    Text {
                        width: parent.width
                        visible: root.expanded && (modelData.status === "failed" || modelData.status === "timeout" || modelData.stdoutText.length > 0 || modelData.stderrText.length > 0)
                        color: modelData.stderrText.length > 0 ? Theme.secondary : Theme.textDim
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
