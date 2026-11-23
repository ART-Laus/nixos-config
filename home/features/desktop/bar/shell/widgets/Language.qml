import QtQuick
import Quickshell.Io
import qs.components
import qs.config
import qs.services

Pill {
    id: root
    tooltip: "Keyboard layout: " + System.layout

    Process {
        id: switchProc
        command: ["hyprctl", "switchxkblayout", Settings.layoutDevice, "next"]
    }

    Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: System.layout
    }

    onClicked: {
        switchProc.running = true;
        System.refreshLayout();
    }
}
