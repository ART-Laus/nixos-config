import QtQuick
import qs.config

Item {
  id: root
  property string imageSource: ""
  property string label: ""
  property int radiusValue: 16

  Rectangle {
    anchors.fill: parent
    radius: root.radiusValue
    color: Qt.rgba(0, 0, 0, 0.38)
    border.width: 1
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)
  }

  Text {
    anchors.centerIn: parent
    visible: image.status !== Image.Ready
    text: root.label ? root.label.charAt(0).toUpperCase() : "♫"
    color: Theme.primary
    opacity: 0.65
    font.family: Theme.fontFamily
    font.pixelSize: Math.max(14, root.width / 3)
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
