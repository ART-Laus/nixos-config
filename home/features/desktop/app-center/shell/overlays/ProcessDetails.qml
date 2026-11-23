import QtQuick
import qs.config
import qs.appcenter.services

Rectangle {
    id: root

    property var processData: null
    readonly property var row: processData || ({})
    property string pendingSignal: ""
    signal closed()

    visible: false
    z: 1500
    width: 540
    height: 440
    radius: AppSettings.surfaceRadius
    color: Theme.tooltip
    border.color: Theme.pill
    border.width: 1

    function humanBytes(value) {
        var bytes = Number(value) || 0;
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(2) + " GB";
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + " MB";
        if (bytes >= 1024)
            return (bytes / 1024).toFixed(1) + " KB";
        return bytes + " B";
    }

    function startedAt(value) {
        var seconds = Number(value) || 0;
        if (seconds <= 0)
            return "unknown";
        return new Date(seconds * 1000).toLocaleString();
    }

    Text {
        id: title
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        text: "Process Details"
        color: Theme.text
        font.pixelSize: Theme.fontSize + 2
        font.bold: true
        font.family: Theme.fontFamily
    }

    Rectangle {
        id: closeBox
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        width: 26
        height: 26
        radius: 13
        color: closeMouse.containsMouse ? Theme.pillHover : Theme.pill
        Text {
            anchors.centerIn: parent
            text: "×"
            color: Theme.textDim
            font.pixelSize: Theme.fontSize + 1
            font.family: Theme.fontFamily
        }
        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.visible = false
        }
    }

    Grid {
        id: fields
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.topMargin: 12
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        columns: 2
        columnSpacing: 18
        rowSpacing: 9

        property real labelWidth: 84
        property real valueWidth: (root.width - 36 - 18) / 2 - 84

        Text { width: fields.labelWidth; text: "Name"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: String(root.row.name || ""); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily; elide: Text.ElideRight }
        Text { width: fields.labelWidth; text: "PID"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: String(root.row.pid || ""); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.labelWidth; text: "Parent PID"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: String(root.row.ppid || ""); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.labelWidth; text: "User"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: String(root.row.user || ""); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily; elide: Text.ElideRight }
        Text { width: fields.labelWidth; text: "Status"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: String(root.row.status || ""); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.labelWidth; text: "Threads"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: String(root.row.num_threads || ""); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.labelWidth; text: "CPU"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: (Number(root.row.cpu_percent) || 0).toFixed(1) + "%"; color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.labelWidth; text: "Memory RSS"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: root.humanBytes(root.row.memory_rss); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.labelWidth; text: "Memory VMS"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: root.humanBytes(root.row.memory_vms); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.labelWidth; text: "Started"; color: Theme.textDim; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily }
        Text { width: fields.valueWidth; text: root.startedAt(root.row.create_time); color: Theme.text; font.pixelSize: Theme.fontSize - 1; font.family: Theme.fontFamily; elide: Text.ElideRight }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: fields.bottom
        anchors.topMargin: 12
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        height: 72
        radius: AppSettings.cardRadius
        color: Theme.pill

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            text: "Command line"
            color: Theme.textDim
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.fontFamily
        }
        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            text: String(root.row.cmdline || "")
            color: Theme.text
            font.pixelSize: Theme.fontSize - 2
            font.family: Theme.fontFamily
            wrapMode: Text.WrapAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16
        spacing: 8

        Rectangle {
            width: 82
            height: 30
            radius: 15
            color: Theme.pillHover
            Text {
                anchors.centerIn: parent
                text: root.row.status === "stopped" ? "Resume" : "Suspend"
                color: Theme.text
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ProcessService.signalProcess(root.row, root.row.status === "stopped" ? "CONT" : "STOP", false)
            }
        }
        Rectangle {
            width: 82
            height: 30
            radius: 15
            color: Theme.warning
            Text {
                anchors.centerIn: parent
                text: "Terminate"
                color: "#0A0A0F"
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
                font.family: Theme.fontFamily
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.pendingSignal = "TERM";
                    confirmDialog.visible = true;
                }
            }
        }
        Rectangle {
            width: 58
            height: 30
            radius: 15
            color: Theme.error
            Text {
                anchors.centerIn: parent
                text: "Kill"
                color: "#0A0A0F"
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
                font.family: Theme.fontFamily
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.pendingSignal = "KILL";
                    confirmDialog.visible = true;
                }
            }
        }
    }

    ConfirmDialog {
        id: confirmDialog
        parent: root
        anchors.centerIn: parent
        title: root.pendingSignal === "KILL" ? "Kill process?" : "Terminate process?"
        message: String(root.row.name || "") + "  PID " + String(root.row.pid || "")
        onConfirmed: ProcessService.signalProcess(root.row, root.pendingSignal, true)
    }

    onVisibleChanged: function () {
        if (!visible)
            root.closed();
    }
}
