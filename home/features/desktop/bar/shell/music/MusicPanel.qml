import QtQuick
import qs.config
import qs.music

Item {
  id: root
  anchors.fill: parent
  signal closeRequested()

  Rectangle {
    anchors.fill: parent
    radius: 26
    color: Qt.rgba(0.02, 0.08, 0.05, 0.94)
    border.width: 1
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
  }

  Item {
    id: header
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: 18
    anchors.rightMargin: 18
    height: 52

    IconButton {
      id: scanButton
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: 40
      height: 36
      radius: 12
      glyph: MusicState.scanning ? "…" : "󰑐"
      disabledButton: MusicState.scanning
      onClicked: MusicState.quickScan()
    }

    Text {
      anchors.left: scanButton.right
      anchors.leftMargin: 12
      anchors.verticalCenter: parent.verticalCenter
      text: MusicState.scanning ? "SCANNING…" : MusicState.backendText
      color: Theme.textDim
      opacity: 0.62
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 2
      font.letterSpacing: 1
    }

    IconButton {
      id: closeButton
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: 40
      height: 36
      radius: 12
      glyph: "󰅖"
      onClicked: root.closeRequested()
    }
  }

  Rectangle {
    id: headerDivider
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: header.bottom
    height: 1
    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.07)
  }

  MiniPlayer {
    id: miniPlayer
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: headerDivider.bottom
    width: parent.width
  }

  Rectangle {
    id: playerDivider
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: miniPlayer.bottom
    height: 1
    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.07)
  }

  Item {
    id: viewStack
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: playerDivider.bottom
    anchors.bottom: parent.bottom
    width: parent.width
    visible: MusicState.view === "search"
    clip: true
    MusicSearch { anchors.fill: parent }
  }

  Item {
    anchors.fill: viewStack
    visible: MusicState.view === "album"
    AlbumView { anchors.fill: parent }
  }

  Item {
    anchors.fill: viewStack
    visible: MusicState.view === "artist"
    ArtistView { anchors.fill: parent }
  }
}
