import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    id: root
    tooltip: Bluetooth.tooltip
    active: Bluetooth.enabled

    Text {
        color: Bluetooth.enabled ? Theme.text : Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: Bluetooth.text
    }

    onClicked: Bluetooth.toggle()
    onRightClicked: UIState.open("bluetooth")
}
