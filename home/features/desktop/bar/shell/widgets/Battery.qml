import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    id: root
    tooltip: Battery.tooltip
    padding: 8

    Text {
        id: label
        color: Battery.critical ? Theme.error : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: Battery.text
    }

    SequentialAnimation {
        running: Battery.critical
        loops: Animation.Infinite
        NumberAnimation { target: label; property: "opacity"; to: 0.25; duration: 500 }
        NumberAnimation { target: label; property: "opacity"; to: 1; duration: 500 }
    }
}
