import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    id: root
    tooltip: "Brightness " + System.brightness + "%"

    Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: System.brightnessText
    }

    onClicked: UIState.open("brightness")
    onWheeled: function (delta) { System.stepBrightness(delta > 0 ? Settings.brightnessStep : -Settings.brightnessStep); }
}
