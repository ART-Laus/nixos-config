import QtQuick
import qs.config
import qs.appcenter.services
import qs.appcenter.components
import qs.appcenter.overlays

Item {
    id: root

    property var selected: null
    property int currentIndex: -1
    property var pendingSignalRow: null
    property string pendingSignal: ""

    signal detailsRequested(var processData)
    signal newProcessRequested()

    function humanBytes(value) {
        var bytes = Number(value) || 0;
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(1) + " GB";
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + " MB";
        if (bytes >= 1024)
            return (bytes / 1024).toFixed(1) + " KB";
        return bytes + " B";
    }

    function widths() {
        if (root.width < 560) {
            var compactFixed = 58 + 58 + 78;
            return [Math.max(90, root.width - compactFixed - 16), 58, 0, 58, 78, 0];
        }
        var fixed = 80 + 110 + 70 + 100 + 90;
        return [Math.max(120, root.width - fixed - 16), 80, 110, 70, 100, 90];
    }

    function move(delta) {
        var count = ProcessService.visibleProcesses.length;
        if (count === 0)
            return;
        var next = root.currentIndex + delta;
        if (next < 0)
            next = 0;
        if (next >= count)
            next = count - 1;
        root.currentIndex = next;
        list.positionViewAtIndex(next, ListView.Contain);
        root.selected = ProcessService.visibleProcesses[next];
    }

    function refresh() {
        ProcessService.snapshotOnce();
    }

    function closeOverlays() {
        contextMenu.visible = false;
        confirmDialog.visible = false;
    }

    function requestSignal(row, sig, confirm) {
        if (!row)
            return;
        if (confirm) {
            root.pendingSignalRow = row;
            root.pendingSignal = sig;
            confirmDialog.visible = true;
        } else {
            ProcessService.signalProcess(row, sig, false);
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Item {
            width: parent.width
            height: 56

            Row {
                anchors.fill: parent
                spacing: 10

                ResourceIndicator {
                    width: (parent.width - 30) / 4
                    height: 56
                    label: "CPU"
                    value: (Number(ProcessService.totals.cpu_percent) || 0).toFixed(1) + "%"
                    ratio: (Number(ProcessService.totals.cpu_percent) || 0) / 100
                    colorValue: (Number(ProcessService.totals.cpu_percent) || 0) >= 75 ? Theme.error : Theme.primary
                }
                ResourceIndicator {
                    width: (parent.width - 30) / 4
                    height: 56
                    label: "RAM"
                    value: humanBytes(ProcessService.totals.memory_used) + " / " + humanBytes(ProcessService.totals.memory_total)
                    ratio: (Number(ProcessService.totals.memory_percent) || 0) / 100
                    colorValue: Theme.primary
                }
                ResourceIndicator {
                    width: (parent.width - 30) / 4
                    height: 56
                    label: "SWAP"
                    value: humanBytes(ProcessService.totals.swap_used) + " / " + humanBytes(ProcessService.totals.swap_total)
                    ratio: (Number(ProcessService.totals.swap_percent) || 0) / 100
                    colorValue: Theme.secondary
                }
                ResourceIndicator {
                    width: (parent.width - 30) / 4
                    height: 56
                    label: "LOAD"
                    value: {
                        var load = ProcessService.totals.loadavg || [];
                        return Number(load[0] || 0).toFixed(2) + " / " + Number(load[1] || 0).toFixed(2);
                    }
                    ratio: Math.min(1, (Number((ProcessService.totals.loadavg || [])[0]) || 0) / 8)
                    colorValue: Theme.warning
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 32
            radius: AppSettings.cardRadius
            color: Theme.pill

            Row {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 0

                Text {
                    width: widths()[0]
                    text: "Name  " + (ProcessService.sortColumn === "name" ? (ProcessService.sortDescending ? "↓" : "↑") : "")
                    color: ProcessService.sortColumn === "name" ? Theme.primary : Theme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                    MouseArea { anchors.fill: parent; onClicked: ProcessService.setSort("name") }
                }
                Text {
                    width: widths()[1]
                    text: "PID" + (ProcessService.sortColumn === "pid" ? (ProcessService.sortDescending ? "↓" : "↑") : "")
                    color: ProcessService.sortColumn === "pid" ? Theme.primary : Theme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                    MouseArea { anchors.fill: parent; onClicked: ProcessService.setSort("pid") }
                }
                Text {
                    width: widths()[2]
                    text: "User" + (ProcessService.sortColumn === "user" ? (ProcessService.sortDescending ? "↓" : "↑") : "")
                    color: ProcessService.sortColumn === "user" ? Theme.primary : Theme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                    MouseArea { anchors.fill: parent; onClicked: ProcessService.setSort("user") }
                }
                Text {
                    width: widths()[3]
                    text: "CPU" + (ProcessService.sortColumn === "cpu_percent" ? (ProcessService.sortDescending ? "↓" : "↑") : "")
                    color: ProcessService.sortColumn === "cpu_percent" ? Theme.primary : Theme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                    MouseArea { anchors.fill: parent; onClicked: ProcessService.setSort("cpu_percent") }
                }
                Text {
                    width: widths()[4]
                    text: "Memory" + (ProcessService.sortColumn === "memory_rss" ? (ProcessService.sortDescending ? "↓" : "↑") : "")
                    color: ProcessService.sortColumn === "memory_rss" ? Theme.primary : Theme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                    MouseArea { anchors.fill: parent; onClicked: ProcessService.setSort("memory_rss") }
                }
                Text {
                    width: widths()[5]
                    text: "Status"
                    color: Theme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                }
            }
        }

        Item {
            width: parent.width
            height: Math.max(0, parent.height - 112)

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                model: ProcessService.visibleProcesses
                currentIndex: root.currentIndex

                delegate: ProcessRow {
                    width: list.width - 8
                    widths: root.widths()
                    processData: modelData
                    selected: index === root.currentIndex
                    onActivate: {
                        root.currentIndex = index;
                        root.selected = modelData;
                        root.detailsRequested(modelData);
                    }
                    onContextRequested: function (mouse) {
                        root.currentIndex = index;
                        root.selected = modelData;
                        root.showContext(modelData, mouse);
                    }
                }
            }

            EmptyState {
                visible: ProcessService.visibleProcesses.length === 0
                anchors.centerIn: parent
                title: "No processes"
                message: ProcessService.query.length > 0 ? "No match for your search" : "Waiting for process snapshot"
            }
        }
    }

    ContextMenu {
        id: contextMenu
        parent: root
        property var processRow: null
        onActionRequested: function (action) {
            var row = contextMenu.processRow;
            if (action === "details")
                root.detailsRequested(row);
            else if (action === "suspend")
                root.requestSignal(row, "STOP", false);
            else if (action === "resume")
                root.requestSignal(row, "CONT", false);
            else if (action === "terminate")
                root.requestSignal(row, "TERM", true);
            else if (action === "kill")
                root.requestSignal(row, "KILL", true);
        }
    }

    function showContext(row, mouse) {
        var stopped = row && row.status === "stopped";
        contextMenu.processRow = row;
        contextMenu.items = [
            { label: "View Details", action: "details" },
            stopped ? { label: "Resume", action: "resume" } : { label: "Suspend", action: "suspend" },
            { label: "Terminate", action: "terminate" },
            { label: "Kill", action: "kill", danger: true }
        ];
        contextMenu.x = Math.min(mouse.x, root.width - contextMenu.width - 8);
        contextMenu.y = Math.min(mouse.y, root.height - contextMenu.height - 8);
        contextMenu.visible = true;
    }

    ConfirmDialog {
        id: confirmDialog
        parent: root
        title: root.pendingSignal === "KILL" ? "Kill process?" : "Terminate process?"
        message: root.pendingSignalRow ? (root.pendingSignalRow.name + "  PID " + root.pendingSignalRow.pid) : ""
        onConfirmed: function () {
            ProcessService.signalProcess(root.pendingSignalRow, root.pendingSignal, true);
            root.pendingSignalRow = null;
        }
    }
}
