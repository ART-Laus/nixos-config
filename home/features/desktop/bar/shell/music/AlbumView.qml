import QtQuick
import qs.config
import qs.music

Item {
  id: root

  Connections {
    target: MusicState
    function onAlbumDataChanged() {
      if (MusicState.albumData && MusicState.albumData.coverArt) {
        MusicState.artworkCache.request(MusicState.albumData.coverArt, 240);
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
      text: "Album"
      color: MusicTheme.accent
      opacity: 1
      font.family: MusicTheme.textFont
      font.pixelSize: MusicTheme.bodyMinor
    }
  }

  CoverImage {
    id: cover
    anchors.left: parent.left
    anchors.leftMargin: 14
    anchors.top: header.bottom
    anchors.topMargin: 10
    width: 112
    height: 112
    radiusValue: 14
    imageSource: MusicState.albumData && MusicState.albumData.coverArt ? MusicState.artworkCache.path(MusicState.albumData.coverArt, 240) : ""
    label: MusicState.albumData ? MusicState.albumData.name : ""
  }

  Column {
    anchors.left: cover.right
    anchors.leftMargin: 14
    anchors.right: parent.right
    anchors.rightMargin: 14
    anchors.top: cover.top
    spacing: 6

    Text {
      width: parent.width
      elide: Text.ElideRight
      text: MusicState.albumData ? MusicState.albumData.name : "Loading album…"
      color: Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: MusicTheme.title
    }

    Text {
      width: parent.width
      elide: Text.ElideRight
      text: MusicState.albumData ? (MusicState.albumData.artist || "Unknown artist") : ""
      color: MusicTheme.text2
      font.family: MusicTheme.textFont
      font.pixelSize: MusicTheme.body
    }

    Text {
      width: parent.width
      elide: Text.ElideRight
      text: MusicState.albumData ? ((MusicState.albumData.year || "") + "  ·  " + ((MusicState.albumData.song || []).length) + " tracks") : ""
      color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.8)
      font.family: Theme.fontFamily
      font.pixelSize: MusicTheme.caption
    }

    Rectangle {
      width: 160
      height: MusicTheme.controlHeight
      radius: MusicTheme.radiusControl
      color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)
      border.width: 1
      border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.35)

      Text {
        anchors.centerIn: parent
        text: "󰐊  Слушать альбом"
        color: Theme.primary
        font.family: Theme.fontFamily
        font.pixelSize: MusicTheme.caption
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: MusicState.playAlbum()
      }
    }
  }

  Flickable {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: cover.bottom
    anchors.topMargin: 12
    anchors.bottom: parent.bottom
    clip: true
    contentHeight: tracks.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
      id: tracks
      width: parent.width
      spacing: 2

      Repeater {
        model: MusicState.albumData ? MusicState.albumData.song || [] : []

        delegate: Item {
          width: tracks.width
          height: MusicTheme.rowHeight

          Rectangle {
            anchors.fill: parent
            radius: 8
            color: trackArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10) : "transparent"
          }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            text: String(index + 1).padStart(2, "0")
            color: Theme.textDim
            opacity: 0.55
            font.family: Theme.fontFamily
            font.pixelSize: MusicTheme.caption
          }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 44
            anchors.right: duration.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: modelData.title
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: MusicTheme.body
          }

          Text {
            id: duration
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: {
              var v = Math.floor(Number(modelData.duration) || 0);
              return Math.floor(v / 60) + ":" + String(v % 60).padStart(2, "0");
            }
            color: Theme.textDim
            opacity: 0.7
            font.family: Theme.fontFamily
            font.pixelSize: MusicTheme.caption
          }

          MouseArea {
            id: trackArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: MusicState.playQueue(MusicState.albumData.song, index)
          }
        }
      }
    }
  }
}
