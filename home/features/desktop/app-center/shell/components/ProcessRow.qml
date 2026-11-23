import QtQuick
import qs.config

Rectangle {
    id: root

    property var processData: null
    property var widths: [0, 80, 110, 70, 100, 90]
    property bool selected: false
    signal activate()
    signal contextRequested(var mouse)

    implicitHeight: AppSettings.rowHeight
    radius: 8
    color: selected ? Theme.pillActive : (mouse.containsMouse ? Theme.pillHover : "transparent")

    Behavior on color {
        ColorAnimation { duration: AppSettings.transitionFast }
    }

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 0
        clip: true

        Text {
            width: root.widths[0]
            elide: Text.ElideRight
            color: Theme.text
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.fontFamily
            text: root.processData ? (root.processData.name || String(root.processData.pid || "")) : ""
        }
        Text {
            width: root.widths[1]
            color: Theme.textDim
            font.pixelSize: Theme.fontSize - 2
            font.family: Theme.fontFamily
            text: root.processData ? String(root.processData.pid || "") : ""
        }
        Text {
            width: root.widths[2]
            elide: Text.ElideRight
            color: Theme.textDim
            font.pixelSize: Theme.fontSize - 2
            font.family: Theme.fontFamily
            text: root.processData ? String(root.processData.user || "") : ""
        }
        Text {
            width: root.widths[3]
            color: {
                if (!root.processData)
                    return Theme.textDim;
                var value = Number(root.processData.cpu_percent) || 0;
                return value >= 75 ? Theme.error : (value >= 35 ? Theme.warning : Theme.text);
            }
            font.pixelSize: Theme.fontSize - 2
            font.family: Theme.fontFamily
            text: root.processData ? (Number(root.processData.cpu_percent || 0).toFixed(1) + "%") : ""
        }
        Text {
            width: root.widths[4]
            color: Theme.textDim
            font.pixelSize: Theme.fontSize - 2
            font.family: Theme.fontFamily
            text: {
                if (!root.processData)
                    return "";
                var mb = (Number(root.processData.memory_rss || 0) / 1048576).toFixed(1);
                return mb + " MB";
            }
        }
        Text {
            width: root.widths[5]
            elide: Text.ElideRight
            color: root.processData && root.processData.status === "stopped" ? Theme.warning : Theme.textDim
            font.pixelSize: Theme.fontSize - 2
            font.family: Theme.fontFamily
            text: root.processData ? String(root.processData.status || "") : ""
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function (event) {
            if (event.button === Qt.RightButton)
                root.contextRequested(event);
            else
                root.activate();
        }
    }
}
