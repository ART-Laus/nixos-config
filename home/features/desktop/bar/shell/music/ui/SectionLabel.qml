import QtQuick
import qs.config
import qs.music

Item {
  id: root
  property string label: ""
  height: 26

  Text {
    id: labelText
    anchors.left: parent.left
    anchors.leftMargin: 2
    anchors.verticalCenter: parent.verticalCenter
    text: root.label.toUpperCase()
    color: MusicTheme.accent
    opacity: 1
    font.family: Theme.fontFamily
    font.pixelSize: MusicTheme.section
    font.letterSpacing: 0.6
  }

  Rectangle {
    anchors.left: labelText.right
    anchors.leftMargin: 10
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    height: 1
    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
  }
}
