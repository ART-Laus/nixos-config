import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    id: root
    tooltip: Audio.sinkTooltip

    Text {
        color: Audio.sinkMuted ? Theme.textDim : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: Audio.sinkText
    }

    onClicked: UIState.open("audio")
    onWheeled: function (delta) { Audio.stepSink(delta > 0 ? Settings.volumeStep : -Settings.volumeStep); }
}
