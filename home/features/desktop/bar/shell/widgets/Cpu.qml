import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    tooltip: "CPU " + Math.round(System.cpuUsage) + "%  " + System.temperature.toFixed(1) + "°C "

    Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: System.cpuText
    }
}
