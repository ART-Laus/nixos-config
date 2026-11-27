import QtQuick
import qs.components
import qs.config
import qs.music

Pill {
  id: root
  property bool expanded: false
  property string label: MusicState.artist ? MusicState.artist + " - " + MusicState.title : MusicState.title
  tooltip: MusicState.connectionStatus === "error" ? MusicState.connectionText
    : MusicState.backendText + " · " + root.label

  Rectangle {
    width: 6
    height: 6
    radius: 3
    color: MusicState.status === "playing" ? Theme.primary
      : MusicState.status === "error" ? Theme.error
      : MusicState.status === "connecting" ? Theme.warning
      : Theme.textDim
    opacity: MusicState.status === "playing" ? 0.95 : 0.55
  }

  MarqueeText {
    width: 240
    implicitWidth: 240
    textValue: root.label
    textColor: Theme.text
    fontSize: MusicTheme.body
    animate: true
  }
}
