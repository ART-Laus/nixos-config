import QtQuick
import qs.config
import qs.music

Item {
  id: root
  property string title: ""
  property string subtitle: ""
  property string coverId: ""
  signal clicked()

  height: MusicTheme.rowHeight

  onCoverIdChanged: {
    if (root.coverId) MusicState.artworkCache.request(root.coverId, 80);
  }

  Rectangle {
    anchors.fill: parent
    radius: MusicTheme.radiusControl
    color: area.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10) : "transparent"
  }

  CoverImage {
    id: art
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 44
    height: 44
    radiusValue: MusicTheme.radiusThumb
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
      font.pixelSize: MusicTheme.body
    }

    Text {
      width: parent.width
      elide: Text.ElideRight
      text: root.subtitle
      color: Theme.textDim
      opacity: 0.72
      font.family: Theme.fontFamily
      font.pixelSize: MusicTheme.caption
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
    font.pixelSize: MusicTheme.icon
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
