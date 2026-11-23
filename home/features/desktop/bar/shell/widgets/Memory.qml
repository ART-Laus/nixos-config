import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    tooltip: "Memory " + Math.round(System.memoryUsage) + "%"

    Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: System.memoryText
    }
}
