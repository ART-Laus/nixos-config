import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.components
import qs.config

Pill {
    id: root

    property var items: []
    padding: 8
    spacing: 7

    function refresh() {
        var values = Hyprland.workspaces ? Hyprland.workspaces.values : [];
        var result = [];
        for (var i = 0; i < values.length; i++) {
            var workspace = values[i];
            if (!workspace) continue;
            if (Hyprland.focusedMonitor && workspace.monitor && workspace.monitor !== Hyprland.focusedMonitor) continue;
            result.push(workspace);
        }
        result.sort(function (a, b) { return a.id - b.id; });
        items = result;
    }

    Repeater {
        model: root.items

        Text {
            required property var modelData
            color: "#C4A0FF"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            text: modelData.active ? "" : ""

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: function () { modelData.activate(); }
            }
        }
    }

    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() { root.refresh(); }
    }

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { root.refresh(); }
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
