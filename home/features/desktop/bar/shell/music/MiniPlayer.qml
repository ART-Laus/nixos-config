import QtQuick
import qs.config
import qs.music

Item {
  id: root
  height: 210
  property bool seekingDrag: false
  property real seekRatio: MusicState.duration > 0 ? Math.min(1, Math.max(0, MusicState.timePos / MusicState.duration)) : 0

  function seekTo(x) {
    if (MusicState.duration <= 0) return;
    var half = seekHandle.width / 2;
    var clamped = Math.min(seekArea.width - half, Math.max(half, x));
    var target = (clamped - half) / Math.max(1, seekArea.width - seekHandle.width) * MusicState.duration;
    MusicState.seek(target - MusicState.timePos);
  }

  CoverImage {
    id: cover
    anchors.left: parent.left
    anchors.leftMargin: 18
    anchors.top: parent.top
    anchors.topMargin: 18
    width: 132
    height: 132
    radiusValue: 20
    imageSource: MusicState.artwork
    label: MusicState.title
  }

  Column {
    anchors.left: cover.right
    anchors.leftMargin: 18
    anchors.right: parent.right
    anchors.rightMargin: 18
    anchors.top: parent.top
    anchors.topMargin: 18
    spacing: 7

    MarqueeText {
      width: parent.width
      implicitWidth: parent.width
      textValue: MusicState.title
      textColor: Theme.text
      fontSize: Theme.fontSize + 3
    }

    MarqueeText {
      width: parent.width
      implicitWidth: parent.width
      textValue: MusicState.artist
      textColor: Theme.textDim
      fontSize: Theme.fontSize - 1
    }

    Text {
      width: parent.width
      elide: Text.ElideRight
      text: MusicState.album ? MusicState.album + (MusicState.year ? "  ·  " + MusicState.year : "") : ""
      color: Theme.textDim
      opacity: 0.62
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 3
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.topMargin: 12
      spacing: 10

      IconButton {
        width: 46
        height: 42
        radius: 14
        glyph: "󰒮"
        onClicked: MusicState.previous()
      }

      IconButton {
        width: 46
        height: 42
        radius: 14
        glyph: "󰴪"
        onClicked: MusicState.seek(-10)
      }

      IconButton {
        width: 56
        height: 48
        radius: 16
        glyph: MusicState.status === "playing" ? "󰏤" : "󰐊"
        active: true
        emphasized: true
        onClicked: MusicState.togglePlay()
      }

      IconButton {
        width: 46
        height: 42
        radius: 14
        glyph: "󰵱"
        onClicked: MusicState.seek(10)
      }

      IconButton {
        width: 46
        height: 42
        radius: 14
        glyph: "󰒭"
        onClicked: MusicState.next()
      }

      IconButton {
        id: favoriteButton
        width: 46
        height: 42
        radius: 14
        glyph: MusicState.favorite ? "󰋑" : "󰋕"
        active: MusicState.favorite
        accentColor: Theme.secondary
        disabledButton: !MusicState.currentSongId
        onClicked: MusicState.toggleFavorite()
      }
    }
  }

  Row {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: 18
    anchors.rightMargin: 18
    anchors.bottomMargin: 12
    spacing: 10

    Text {
      id: elapsed
      width: 48
      anchors.verticalCenter: parent.verticalCenter
      text: {
        var v = Math.floor(MusicState.timePos);
        return Math.floor(v / 60) + ":" + String(v % 60).padStart(2, "0");
      }
      color: Theme.textDim
      opacity: 0.75
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 3
    }

    Item {
      id: seekArea
      width: root.width - 36 - elapsed.width - remaining.width - 20
      height: 36
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        id: seekTrack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 8
        radius: 4
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, seekMouse.containsMouse || root.seekingDrag ? 0.18 : 0.12)
      }

      Rectangle {
        anchors.left: seekTrack.left
        anchors.verticalCenter: seekTrack.verticalCenter
        width: seekTrack.width * root.seekRatio
        height: seekTrack.height
        radius: seekTrack.radius
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, seekMouse.containsMouse || root.seekingDrag ? 0.85 : 0.65)
      }

      Rectangle {
        id: seekHandle
        width: seekMouse.containsMouse || root.seekingDrag ? 18 : 14
        height: width
        radius: width / 2
        x: Math.min(seekArea.width - width / 2, Math.max(width / 2, root.seekRatio * seekArea.width - width / 2))
        anchors.verticalCenter: seekTrack.verticalCenter
        color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.35)

        Behavior on width { NumberAnimation { duration: 120 } }
      }

      MouseArea {
        id: seekMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: function (mouse) {
          if (mouse.button !== Qt.LeftButton) return;
          root.seekingDrag = true;
          MusicState.seeking = true;
          root.seekTo(mouse.x);
          mouse.accepted = true;
        }

        onPositionChanged: function (mouse) {
          if (root.seekingDrag) root.seekTo(mouse.x);
        }

        onReleased: function (mouse) {
          if (!root.seekingDrag) return;
          root.seekTo(mouse.x);
          root.seekingDrag = false;
          MusicState.seeking = false;
        }

        onCanceled: function () {
          root.seekingDrag = false;
          MusicState.seeking = false;
        }

        onWheel: function (wheel) {
          if (MusicState.duration <= 0) return;
          var steps = wheel.angleDelta.y / 120;
          if (steps) MusicState.seek(steps * 5);
          wheel.accepted = true;
        }
      }

      Component.onDestruction: MusicState.seeking = false
    }

    Text {
      id: remaining
      width: 48
      anchors.verticalCenter: parent.verticalCenter
      text: {
        var v = Math.floor(MusicState.duration);
        return Math.floor(v / 60) + ":" + String(v % 60).padStart(2, "0");
      }
      color: Theme.textDim
      opacity: 0.75
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize - 3
    }
  }
}
