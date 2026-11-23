import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    id: root
    tooltip: Network.tooltip

    Text {
        color: Network.connected ? Theme.text : Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: Network.text
    }

    onClicked: UIState.open("network")
}
