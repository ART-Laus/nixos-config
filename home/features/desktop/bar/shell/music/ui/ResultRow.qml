import QtQuick
import qs.config
import qs.music

Item {
  id: root
  property string title: ""
  property string subtitle: ""
  property string coverId: ""
  signal clicked()

  height: 54

  onCoverIdChanged: {
    if (root.coverId) MusicState.artworkCache.request(root.coverId, 80);
  }

  Rectangle {
    anchors.fill: parent
    radius: 9
    color: area.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10) : "transparent"
  }

  CoverImage {
    id: art
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 40
    height: 40
    radiusValue: 7
    imageSource: MusicState.artworkCache.path(root.coverId, 80)
    label: root.title
  }

  Column {
    anchors.left: art.right
    anchors.leftMargin: 10
    anchors.right: chevron.left
    anchors.rightMargin: 6
    anchors.verticalCenter: parent.verticalCenter
    spacing: 3

    Text {
      width: parent.width
      elide: Text.ElideRight
      text: root.title
      color: Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 1
    }

    Text {
      width: parent.width
      elide: Text.ElideRight
      text: root.subtitle
      color: Theme.textDim
      opacity: 0.72
      font.family: Theme.fontFamily
      font.pixelSize: 10
    }
  }

  Text {
    id: chevron
    anchors.right: parent.right
    anchors.rightMargin: 8
    anchors.verticalCenter: parent.verticalCenter
    text: "󰒭"
    color: Theme.primary
    opacity: area.containsMouse ? 0.9 : 0.35
    font.family: Theme.fontFamily
    font.pixelSize: 18
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
