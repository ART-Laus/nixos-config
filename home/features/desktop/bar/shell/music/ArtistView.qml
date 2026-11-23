import QtQuick
import qs.config
import qs.music

Item {
  id: root

  Connections {
    target: MusicState
    function onArtistDataChanged() {
      var data = MusicState.artistData;
      if (data && data.album && data.album.length && data.album[0].coverArt) {
        MusicState.artworkCache.request(data.album[0].coverArt, 160);
      }
    }
  }

  Row {
    id: header
    anchors.left: parent.left
    anchors.leftMargin: 14
    anchors.right: parent.right
    anchors.rightMargin: 14
    anchors.top: parent.top
    spacing: 10

    IconButton {
      glyph: "󰒮"
      onClicked: MusicState.back()
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "Artist"
      color: Theme.primary
      opacity: 0.75
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 2
    }
  }

  Text {
    anchors.left: header.left
    anchors.right: header.right
    anchors.top: header.bottom
    anchors.topMargin: 12
    elide: Text.ElideRight
    text: MusicState.artistData ? MusicState.artistData.name : "Loading artist…"
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize + 2
  }

  Flickable {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: header.bottom
    anchors.topMargin: 48
    anchors.bottom: parent.bottom
    clip: true
    contentHeight: albums.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
      id: albums
      width: parent.width
      spacing: 8

      Repeater {
        model: MusicState.artistData ? MusicState.artistData.album || [] : []

        delegate: Item {
          width: albums.width
          height: 62

          Component.onCompleted: {
            if (modelData.coverArt) MusicState.artworkCache.request(modelData.coverArt, 100);
          }

          Rectangle {
            anchors.fill: parent
            radius: 10
            color: area.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10) : "transparent"
          }

          CoverImage {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            width: 46
            height: 46
            radiusValue: 8
            imageSource: modelData.coverArt ? MusicState.artworkCache.path(modelData.coverArt, 100) : ""
            label: modelData.name
          }

          Column {
            anchors.left: parent.left
            anchors.leftMargin: 72
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
              width: parent.width
              elide: Text.ElideRight
              text: modelData.name
              color: Theme.text
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize - 1
            }

            Text {
              width: parent.width
              elide: Text.ElideRight
              text: modelData.year ? String(modelData.year) : "Album"
              color: Theme.textDim
              opacity: 0.7
              font.family: Theme.fontFamily
              font.pixelSize: 10
            }
          }

          MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: MusicState.openAlbum(modelData.id)
          }
        }
      }
    }
  }
}
