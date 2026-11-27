import QtQuick
import qs.config
import qs.music

Item {
  id: root
  property bool hasQuery: String(MusicState.query || "").trim().length > 0

  Rectangle {
    id: searchBox
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: MusicTheme.controlHeight
    radius: MusicTheme.radiusControl
    color: MusicTheme.surface
    border.width: 1
    border.color: Theme.border

    Text {
      anchors.left: parent.left
      anchors.leftMargin: 12
      anchors.verticalCenter: parent.verticalCenter
      text: "󰍉"
      color: Theme.primary
      opacity: 0.75
      font.family: Theme.fontFamily
      font.pixelSize: MusicTheme.icon
    }

    TextInput {
      id: input
      anchors.left: parent.left
      anchors.leftMargin: 34
      anchors.right: clearButton.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      focus: true
      color: Theme.text
      font.family: Theme.fontFamily
      font.pixelSize: MusicTheme.body
      text: MusicState.query
      onTextChanged: MusicState.search(text)
    }

    Text {
      anchors.left: input.left
      anchors.verticalCenter: parent.verticalCenter
      visible: !input.text && !input.activeFocus
      text: "Поиск артистов, альбомов, треков…"
      color: Theme.textDim
      opacity: 0.55
      font.family: Theme.fontFamily
      font.pixelSize: MusicTheme.body
    }

    IconButton {
      id: clearButton
      anchors.right: parent.right
      anchors.rightMargin: 5
      anchors.verticalCenter: parent.verticalCenter
      width: MusicTheme.buttonSize
      height: MusicTheme.controlHeight
      glyph: "󰅖"
      onClicked: {
        input.text = "";
        input.forceActiveFocus();
      }
    }
  }

  Text {
    id: statusLine
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: searchBox.bottom
    anchors.topMargin: 7
    elide: Text.ElideRight
    text: MusicState.connectionStatus === "error" ? MusicState.connectionText
      : MusicState.connectionStatus === "connecting" ? "Connecting to Navidrome…"
      : MusicState.query ? "Результаты: “" + MusicState.query + "”"
      : "Введите запрос для поиска по всей библиотеке"
    color: MusicState.connectionStatus === "error" ? Theme.error : Theme.textDim
    opacity: 0.75
    font.family: Theme.fontFamily
    font.pixelSize: MusicTheme.caption
  }

  Flickable {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: statusLine.bottom
    anchors.topMargin: 8
    anchors.bottom: parent.bottom
    clip: true
    contentHeight: content.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    Column {
      id: content
      width: parent.width
      spacing: 10

      SectionLabel {
        label: "Альбомы (" + MusicState.searchResults.album.length + ")"
        visible: root.hasQuery
      }
      Repeater {
        model: MusicState.searchResults.album
        delegate: ResultRow {
          width: content.width
          title: modelData.name
          subtitle: (modelData.artist || "Неизвестный артист") + (modelData.year ? " · " + modelData.year : "")
          coverId: modelData.coverArt
          onClicked: MusicState.openAlbum(modelData.id)
        }
      }

      SectionLabel {
        label: "Артисты (" + MusicState.searchResults.artist.length + ")"
        visible: root.hasQuery
      }
      Repeater {
        model: MusicState.searchResults.artist
        delegate: ResultRow {
          width: content.width
          title: modelData.name
          subtitle: "Артист"
          coverId: modelData.coverArt
          onClicked: MusicState.openArtist(modelData.id)
        }
      }

      SectionLabel {
        label: "Треки (" + MusicState.searchResults.song.length + ")"
        visible: root.hasQuery
      }
      Repeater {
        model: MusicState.searchResults.song
        delegate: ResultRow {
          width: content.width
          title: modelData.title
          subtitle: (modelData.artist || "Неизвестный артист") + " · " + (modelData.album || "")
          coverId: modelData.coverArt
          onClicked: MusicState.playTrack(modelData)
        }
      }

      Text {
        width: content.width
        visible: root.hasQuery && !MusicState.searchResults.album.length && !MusicState.searchResults.artist.length && !MusicState.searchResults.song.length && MusicState.connectionStatus !== "connecting"
        horizontalAlignment: Text.AlignHCenter
        text: MusicState.connectionStatus === "error" ? "Поиск недоступен — проверьте соединение" : "Совпадений нет"
        color: Theme.textDim
        opacity: 0.7
        font.family: Theme.fontFamily
        font.pixelSize: MusicTheme.bodyMinor
      }

      Text {
        width: content.width
        visible: !root.hasQuery
        horizontalAlignment: Text.AlignHCenter
        text: "Введите запрос для поиска по всей библиотеке"
        color: Theme.textDim
        opacity: 0.55
        font.family: Theme.fontFamily
        font.pixelSize: MusicTheme.bodyMinor
      }
    }
  }
}
