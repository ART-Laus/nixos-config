import QtQuick
import qs.config

Item {
  id: root
  property string label: ""
  height: 22

  Text {
    id: labelText
    anchors.left: parent.left
    anchors.leftMargin: 2
    anchors.verticalCenter: parent.verticalCenter
    text: root.label.toUpperCase()
    color: Theme.primary
    opacity: 0.6
    font.family: Theme.fontFamily
    font.pixelSize: 10
    font.letterSpacing: 1.2
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
