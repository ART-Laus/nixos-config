import QtQuick
import qs.components
import qs.config
import qs.services

Pill {
    tooltip: System.nowPlaying || "Nothing playing"

    Text {
        width: Math.min(implicitWidth, 320)
        elide: Text.ElideRight
        color: System.nowPlaying ? Theme.text : Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: " " + System.nowPlaying
    }
}
