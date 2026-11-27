import QtQuick
import qs.config
import qs.music

Item {
  id: root
  property string imageSource: ""
  property string label: ""
  property int radiusValue: MusicTheme.radiusCard

  Rectangle {
    anchors.fill: parent
    radius: root.radiusValue
    color: Theme.panelAlt
    border.width: 1
    border.color: Theme.border
  }

  Text {
    anchors.centerIn: parent
    visible: image.status !== Image.Ready
    text: root.label ? root.label.charAt(0).toUpperCase() : "♫"
    color: MusicTheme.accent
    opacity: 0.9
    font.family: Theme.fontFamily
    font.pixelSize: MusicTheme.icon
  }

  Image {
    id: image
    anchors.fill: parent
    anchors.margins: 1
    source: root.imageSource
    fillMode: Image.PreserveAspectCrop
    smooth: true
    asynchronous: true
    visible: status === Image.Ready
  }
}
