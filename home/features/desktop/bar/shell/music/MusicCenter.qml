import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.music

Item {
  id: root
  width: pill.implicitWidth
  height: pill.implicitHeight
  property bool expanded: false

  IpcHandler {
    target: "musicCenter"
    function toggle(): void { root.expanded = !root.expanded; }
    function state(): string { return root.expanded ? "open" : "closed"; }
    function debug(): string {
      var results = MusicState.searchResults;
      return JSON.stringify({
        backend: MusicState.backend,
        preferredMode: MusicState.preferredMode,
        mprisMode: MusicState.mpris.mode,
        hasMprisPlayer: !!MusicState.mpris.player,
        status: MusicState.status,
        connectionStatus: MusicState.connectionStatus,
        browserArtKey: MusicState.browserArtKey,
        browserLookupAttempts: MusicState.browserLookupAttempts,
        pendingBrowserPlay: !!MusicState.pendingBrowserPlay,
        lastError: MusicState.lastError,
        canControl: !!MusicState.mpris.caps.canControl,
        canSeek: !!MusicState.mpris.caps.canSeek,
        title: MusicState.title,
        artist: MusicState.artist,
        album: MusicState.album,
        year: MusicState.year,
        timePos: MusicState.timePos,
        duration: MusicState.duration,
        seeking: MusicState.seeking,
        favorite: MusicState.favorite,
        currentSongId: MusicState.currentSongId,
        scanning: MusicState.scanning,
        hover: hoverArea.containsMouse,
        counts: {
          album: results.album ? results.album.length : 0,
          artist: results.artist ? results.artist.length : 0,
          song: results.song ? results.song.length : 0
        }
      });
    }
    function debugSearch(text: string): void { MusicState.search(text); }
    function debugSeek(seconds: real): void { MusicState.seek(seconds); }
    function debugToggle(): void { MusicState.togglePlay(); }
    function debugPlay(id: string): void {
      var songs = MusicState.searchResults.song || [];
      for (var i = 0; i < songs.length; i++) {
        if (String(songs[i].id) === id) {
          MusicState.playTrack(songs[i]);
          return;
        }
      }
    }
  }

  CompactPill {
    id: pill
    anchors.fill: parent
    expanded: root.expanded
  }

  PopupWindow {
    id: panel
    implicitWidth: 680
    implicitHeight: 760
    color: "transparent"
    grabFocus: false
    surfaceFormat.opaque: false
    visible: root.expanded
    anchor.item: pill
    anchor.edges: Edges.Top
    anchor.gravity: Edges.Top
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
    anchor.margins.top: -8
    mask: Region { item: panelContent; radius: Settings.popupRadius }
    BackgroundEffect.blurRegion: Region { item: panelContent; radius: Settings.popupRadius }
    onClosed: root.expanded = false

    Item {
      id: keySink
      anchors.fill: parent
      focus: true

      property int lastDir: 0
      property int lastAt: 0

      Timer {
        id: tapReset
        interval: 300
        onTriggered: keySink.lastDir = 0
      }

      function arrow(dir) {
        var now = Date.now();
        var doubleTap = keySink.lastDir === dir && now - keySink.lastAt <= 300;
        keySink.lastDir = doubleTap ? 0 : dir;
        keySink.lastAt = now;
        if (doubleTap) {
          tapReset.stop();
          MusicState.seek(dir > 0 ? 5 : -5);
        } else {
          tapReset.restart();
        }
      }

      Keys.onPressed: function (event) {
        if (!root.expanded || !hoverArea.containsMouse || event.isAutoRepeat) return;
        if (event.key === Qt.Key_Right) {
          keySink.arrow(1);
          event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
          keySink.arrow(-1);
          event.accepted = true;
        } else if (event.key === Qt.Key_Space) {
          MusicState.togglePlay();
          event.accepted = true;
        }
      }
    }

    MouseArea {
      id: hoverArea
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.NoButton
      propagateComposedEvents: true
      onEntered: keySink.forceActiveFocus()
      onExited: {
        keySink.lastDir = 0;
        tapReset.stop();
      }
    }

    Connections {
      target: panel
      function onVisibleChanged() {
        if (panel.visible && hoverArea.containsMouse) keySink.forceActiveFocus();
        else {
          keySink.lastDir = 0;
          tapReset.stop();
        }
      }
    }

    MusicPanel {
      id: panelContent
      anchors.fill: parent
      onCloseRequested: root.expanded = false
    }
  }

  HyprlandFocusGrab {
    active: root.expanded
    windows: [panel]

    onCleared: function () {
      if (root.expanded) root.expanded = false;
    }
  }

  Connections {
    target: pill
    function onClicked(mouse) {
      root.expanded = !root.expanded;
    }
    function onMiddleClicked(mouse) {
      MusicState.togglePlay();
    }
  }

  onExpandedChanged: function () {
    if (!root.expanded && MusicState.view !== "search") MusicState.back();
  }
}
