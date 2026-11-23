import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.music

Item {
  id: root
  width: 320
  height: Settings.barHeight

  property bool lockedOpen: false
  readonly property bool expanded: lockedOpen
  property bool interacting: false
  property string panelView: "media"
  property bool showLyrics: false

  property string textFont: bricolage.name || "Bricolage Grotesque"
  property string iconFont: Theme.fontFamily
  property color islandFill: Qt.rgba(0, 0, 0, 0.85)
  property color surface: "#001a0d"
  property color surfaceAlt: "#0d3322"
  property color text: "#c0ffc0"
  property color subtext: "#8bcf9f"
  property color muted: "#448866"
  property color line: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)
  property color lineStrong: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.34)
  property color chip: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
  property color chipHover: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)
  property color accent: Theme.primary
  property color accentText: "#001a0d"
  property color track: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)
  property color secondary: Theme.secondary

  property real playGlow: 0
  property real ringPulse: 1
  property real visualPhase: 0
    property real displayPosition: 0
  property bool seeking: false

  onPanelViewChanged: {
    if (root.panelView === "search") {
      root.openPanel();
      Qt.callLater(function() { searchField.forceActiveFocus(); });
    }
  }

  readonly property string mediaStatus:
 MusicState.status === "playing" ? "Playing"
    : MusicState.status === "paused" ? "Paused" : "Stopped"
  readonly property string mediaTitle: MusicState.title || "Carpheus Music"
  readonly property string mediaArtist: MusicState.artist || "Unknown artist"
  readonly property string mediaAlbum: MusicState.album || ""
  readonly property string mediaAlbumLine: {
    var name = MusicState.album || "";
    var year = String(MusicState.year || "");
    if (!name && !year) return "";
    return (name || "Unknown album") + (year ? " · " + year : "");
  }
  readonly property string mediaArt: MusicState.artwork || ""
  readonly property string currentAlbumId: MusicState.currentTrack && MusicState.currentTrack.albumId ? String(MusicState.currentTrack.albumId) : ""
  readonly property string currentArtistId: MusicState.currentTrack && MusicState.currentTrack.artistId ? String(MusicState.currentTrack.artistId) : ""
  readonly property string mediaPlayer: MusicState.backendText || "Navidrome"
  readonly property real mediaLength: Number(MusicState.duration) || 0
  readonly property bool mediaLengthKnown: mediaLength > 0
  readonly property bool idleView: mediaStatus === "Stopped"

  FontLoader {
    id: bricolage
    source: "assets/BricolageGrotesque.ttf"
  }

  SequentialAnimation on playGlow {
    running: root.mediaStatus === "Playing"
    loops: Animation.Infinite
    onRunningChanged: if (!running) root.playGlow = 0
    NumberAnimation { from: 0; to: 1; duration: 1300; easing.type: Easing.InOutSine }
    NumberAnimation { from: 1; to: 0; duration: 1300; easing.type: Easing.InOutSine }
  }

  NumberAnimation on ringPulse {
    running: root.mediaStatus === "Playing" && !root.expanded
    loops: Animation.Infinite
    from: 0
    to: 1
    duration: 1100
    easing.type: Easing.OutCubic
    onRunningChanged: if (!running) root.ringPulse = 1
  }

  NumberAnimation on visualPhase {
    running: root.mediaStatus === "Playing"
    loops: Animation.Infinite
    from: 0
    to: Math.PI * 2
    duration: 1100
    onRunningChanged: if (!running) root.visualPhase = 0
  }

  Timer {
    interval: 250
    repeat: true
    running: root.mediaStatus === "Playing" && !root.seeking
    onTriggered: {
      var limit = root.mediaLength
      var next = root.displayPosition + 0.25
      root.displayPosition = limit > 0 ? Math.min(limit, next) : next
    }
  }

  Connections {
    target: MusicState
    function onTimePosChanged() { if (!root.seeking) root.displayPosition = MusicState.timePos; }
    function onStatusChanged() {
      root.seeking = false;
      root.displayPosition = MusicState.timePos;
    }
  }

  function openPanel() {
    root.lockedOpen = true;
  }

  function closePanel() {
    root.lockedOpen = false;
    root.interacting = false;
    root.panelView = "media";
  }

  function togglePanel() {
    if (root.expanded) closePanel();
    else openPanel();
  }

  function mediaAction(command) {
    if (command === "play-pause") MusicState.togglePlay();
    else if (command === "previous") MusicState.previous();
    else if (command === "next") MusicState.next();
    else if (command === "shuffle") MusicState.setShuffle(!MusicState.shuffle);
    else if (command === "loop") MusicState.cycleRepeat();
    else if (command === "favorite") MusicState.toggleFavorite();
  }

  function formatTime(value) {
    var total = Math.max(0, Math.floor(Number(value) || 0));
    var minutes = Math.floor(total / 60);
    var seconds = total % 60;
    return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
  }

  function coverFor(id) {
    if (!id) return "";
    var cached = MusicState.artworkCache.path(id, 300);
    if (!cached) MusicState.artworkCache.request(id, 300);
    return cached;
  }

  function openCurrentAlbum() {
    root.openPanel();
    if (root.currentAlbumId) {
      MusicState.openAlbum(root.currentAlbumId);
      root.panelView = "album";
    } else if (root.mediaAlbum) {
      root.panelView = "search";
      MusicState.search(root.mediaAlbum);
    }
  }

  function openCurrentArtist() {
    root.openPanel();
    if (root.currentArtistId) {
      MusicState.openArtist(root.currentArtistId);
      root.panelView = "artist";
    } else if (root.mediaArtist && root.mediaArtist !== "Unknown artist") {
      root.panelView = "search";
      MusicState.search(root.mediaArtist);
    }
  }

  IpcHandler {
    target: "musicCenter"
    function toggle(): void { root.togglePanel(); }
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
        lastError: MusicState.lastError,
        canControl: !!MusicState.mpris.caps.canControl,
        canSeek: !!MusicState.mpris.caps.canSeek,
        title: MusicState.title,
        artist: MusicState.artist,
        album: MusicState.album,
        year: MusicState.year,
        timePos: MusicState.timePos,
        duration: MusicState.duration,
        favorite: MusicState.favorite,
        currentSongId: MusicState.currentSongId,
        currentAlbumId: root.currentAlbumId,
        currentArtistId: root.currentArtistId,
        artwork: MusicState.artwork,
        browserCover: MusicState.browserCover,
        playerAvailable: MusicState.player.available,
        playerSocketPath: MusicState.player.socketPath,
        playerMpvRunning: MusicState.player.mpv.running,
        playerIpcRunning: MusicState.player.ipc.running,
        playerCommandRunning: MusicState.player.commandProc.running,
        playerPendingBatches: (MusicState.player.pendingBatches || []).length,
        playerPending: !!MusicState.player.pendingPlay,
        playerQueue: (MusicState.player.queue || []).length,
        playerCurrent: !!MusicState.player.currentTrack,
        playerError: MusicState.player.error,
        artworkPaths: Object.keys(MusicState.artworkCache.paths || {}).length,
        lyricsLines: (MusicState.lyricsLines || []).length,
        lyricsSynced: MusicState.lyricsSynced,
        scanning: MusicState.scanning,
        panelView: root.panelView,
        panelHeight: panel.height,
        miniTransportVisible: miniTransport.visible,
        miniSeek: miniSeekSlider.value,
        albumLoaded: !!MusicState.albumData,
        artistLoaded: !!MusicState.artistData,
        expanded: root.expanded,
        searchFocused: searchField.activeFocus,
        searchText: searchField.text,
        hover: pillHover.hovered,
        counts: {
          album: results.album ? results.album.length : 0,
          artist: results.artist ? results.artist.length : 0,
          song: results.song ? results.song.length : 0
        }
      });
    }
    function debugSearch(text: string): void {
      root.panelView = "search";
      MusicState.search(text);
    }
    function debugSeek(seconds: real): void { MusicState.seek(seconds); }
    function debugToggle(): void { MusicState.togglePlay(); }
    function debugFavorite(): void { MusicState.toggleFavorite(); }
    function debugOpenAlbum(): void { root.openCurrentAlbum(); }
    function debugOpenArtist(): void { root.openCurrentArtist(); }
    function debugPlay(id: string): void {
      var songs = MusicState.searchResults.song || [];
      for (var i = 0; i < songs.length; i++) {
        if (String(songs[i].id) === id) {
          MusicState.playTrack(songs[i]);
          root.panelView = "media";
          return;
        }
      }
    }
  }

  Rectangle {
    id: pill
    width: Math.max(296, Math.min(360, pillContent.implicitWidth + 34))
    height: root.height
    radius: Math.max(9, Math.floor(root.height * 0.34))
    color: root.islandFill
    border.width: 1
    border.color: root.line
    clip: true

      HoverHandler {
        id: pillHover
      }


    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
      z: -1
      onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) MusicState.togglePlay();
        else if (mouse.button === Qt.RightButton) root.closePanel();
        else root.togglePanel();
      }
    }

    Rectangle {
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 0.65
      height: 1
      color: root.lineStrong
      opacity: 0.45 + root.playGlow * 0.35
    }

    Spectrum {
      anchors.fill: parent
      anchors.margins: 3
      bars: 48
      barSpacing: 2
      fillWidth: true
      peak: Math.max(6, height - 8)
      floorHeight: 1
      mirrored: true
      baseAlpha: 0.03
      gainAlpha: 0.24
      z: 0
    }

    RowLayout {
      id: pillContent
      z: 2
      anchors.centerIn: parent
      spacing: 10

      Item {
        visible: !root.idleView
        Layout.preferredWidth: 22
        Layout.preferredHeight: 22

        Rectangle {
          anchors.fill: parent
          radius: 7
          color: root.surface
          clip: true
          border.width: 1
          border.color: root.lineStrong
          FadeArt {
            id: pillArt
            anchors.fill: parent
            source: root.mediaArt
          }
          Text {
            anchors.centerIn: parent
            visible: pillArt.status !== Image.Ready
            text: "󰎈"
            color: root.muted
            font.family: root.iconFont
            font.pixelSize: 12
          }
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openCurrentAlbum()
          }
        }

        Rectangle {
          anchors.centerIn: parent
          width: parent.width + 6
          height: parent.height + 6
          radius: width / 2
          color: "transparent"
          border.width: 1
          border.color: root.accent
          visible: root.mediaStatus === "Playing"
          opacity: (1 - root.ringPulse) * 0.5
          scale: 0.86 + root.ringPulse * 0.4
        }
      }

      FadeText {
        visible: !root.idleView
        Layout.maximumWidth: 190
        text: root.mediaTitle
        elide: Text.ElideRight
        color: root.text
        font.family: root.textFont
        font.weight: Font.DemiBold
        font.pixelSize: 13
      }

      FadeText {
        visible: root.idleView
        text: "Carpheus Music"
        color: root.text
        font.family: root.textFont
        font.weight: Font.DemiBold
        font.pixelSize: 13
      }

      Row {
        spacing: 2
        CompactTransportButton { icon: "󰒮"; onTriggered: root.mediaAction("previous") }
        CompactTransportButton {
          icon: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
          primary: true
          onTriggered: root.mediaAction("play-pause")
        }
        CompactTransportButton { icon: "󰒭"; onTriggered: root.mediaAction("next") }
      }
    }

    Rectangle {
      visible: !root.idleView && root.mediaLengthKnown
      z: 3
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      anchors.leftMargin: 12
      anchors.rightMargin: 12
      anchors.bottomMargin: 2
      height: 2
      radius: 1
      color: root.track
      Rectangle {
        width: parent.width * Math.max(0, Math.min(1, root.displayPosition / Math.max(1, root.mediaLength)))
        height: parent.height
        radius: parent.radius
        color: root.accent
        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
      }
    }
  }

  PopupWindow {
    id: panel
    implicitWidth: Math.min(780, Screen.width - 40)
    implicitHeight: root.panelView === "media" || root.idleView ? 324 : 360
    Behavior on implicitHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    color: "transparent"
    grabFocus: root.lockedOpen
    surfaceFormat.opaque: false
    visible: root.expanded
    anchor.item: pill
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Top
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
    anchor.margins.top: 8
    mask: Region { item: panelSurface; radius: 20 }
    BackgroundEffect.blurRegion: Region { item: panelSurface; radius: 20 }
    onClosed: {
      root.lockedOpen = false;
    }

    Item {
      id: panelSurface
      anchors.fill: parent

      Rectangle {
        anchors.fill: parent
        radius: 20
        color: root.islandFill
        border.width: 1
        border.color: root.line
      }

      Item {
        id: keySink
        anchors.fill: parent
        focus: root.expanded
        Keys.enabled: root.expanded
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) {
            root.closePanel();
            event.accepted = true;
          } else if (event.key === Qt.Key_Space) {
            root.mediaAction("play-pause");
            event.accepted = true;
          } else if (event.key === Qt.Key_Left) {
            MusicState.seek(-5);
            event.accepted = true;
          } else if (event.key === Qt.Key_Right) {
            MusicState.seek(5);
            event.accepted = true;
          }
        }
      }

      RowLayout {
        id: statusStrip
        anchors { top: parent.top; left: parent.left; right: parent.right }
        anchors.topMargin: 12
        anchors.leftMargin: 20
        anchors.rightMargin: 18
        height: 26
        spacing: 10

        RowLayout {
          Layout.fillWidth: true
          spacing: 8
          Rectangle {
            Layout.preferredWidth: 6
            Layout.preferredHeight: 6
            radius: 3
            color: root.mediaStatus === "Playing" ? root.accent : root.muted
          }
          FadeText {
            Layout.fillWidth: true
            text: root.panelView === "media" ? "MEDIA" : root.panelView === "search" ? "SEARCH" : root.panelView.toUpperCase()
            color: root.subtext
            font.family: root.textFont
            font.weight: Font.DemiBold
            font.pixelSize: 12
            elide: Text.ElideRight
          }
        }

        PanelChip {
          visible: root.panelView !== "search"
          icon: "󰍉"
          lit: root.panelView === "search"
          onTriggered: root.panelView = "search"
        }
        PanelChip {
          visible: root.panelView !== "media"
          icon: "󰅁"
          onTriggered: {
            if (root.panelView === "search") root.panelView = "media";
            else {
              MusicState.back();
              root.panelView = "search";
            }
          }
        }
        PanelChip {
          visible: root.panelView === "media"
          icon: "󰨖"
          lit: root.showLyrics
          onTriggered: root.showLyrics = !root.showLyrics
        }
        PanelChip {
          icon: root.lockedOpen ? "󰐃" : "󰤱"
          lit: root.lockedOpen
          onTriggered: {
            if (root.lockedOpen) root.closePanel();
            else root.openPanel();
          }
        }
        PanelChip {
          icon: "󰅖"
          danger: true
          onTriggered: root.closePanel()
        }
      }

      Rectangle {
        id: miniTransport
        visible: root.panelView !== "media" && !root.idleView
        anchors { top: statusStrip.bottom; left: parent.left; right: parent.right }
        anchors.topMargin: 8
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        height: 62
        radius: 12
        color: root.surfaceAlt
        border.width: 1
        border.color: root.line

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 8
          spacing: 2

          RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 10

            Rectangle {
              Layout.preferredWidth: 32
              Layout.preferredHeight: 32
              radius: 9
              color: root.surface
              clip: true
              border.width: 1
              border.color: root.lineStrong
              FadeArt {
                id: miniArt
                anchors.fill: parent
                source: root.mediaArt
              }
              Text {
                anchors.centerIn: parent
                visible: miniArt.status !== Image.Ready
                text: "󰎈"
                color: root.muted
                font.family: root.iconFont
                font.pixelSize: 14
              }
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openCurrentAlbum()
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 0
              FadeText {
                Layout.fillWidth: true
                text: root.mediaTitle
                color: root.text
                font.family: root.textFont
                font.weight: Font.DemiBold
                font.pixelSize: 11
                elide: Text.ElideRight
              }
              FadeText {
                Layout.fillWidth: true
                text: root.mediaArtist
                color: root.muted
                font.family: root.textFont
                font.pixelSize: 9
                elide: Text.ElideRight
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.openCurrentArtist()
                }
              }
            }

            Text {
              text: root.formatTime(root.displayPosition) + (root.mediaLengthKnown ? " / " + root.formatTime(root.mediaLength) : "")
              color: root.muted
              font.family: root.textFont
              font.pixelSize: 9
            }

            Row {
              spacing: 2
              MiniControl {
                icon: MusicState.shuffle ? "󰒝" : "󰒞"
                lit: MusicState.shuffle
                onTriggered: root.mediaAction("shuffle")
              }
              CompactTransportButton { icon: "󰒮"; onTriggered: root.mediaAction("previous") }
              CompactTransportButton {
                icon: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                primary: true
                onTriggered: root.mediaAction("play-pause")
              }
              CompactTransportButton { icon: "󰒭"; onTriggered: root.mediaAction("next") }
              MiniControl {
                icon: MusicState.repeat === 2 ? "󰑘" : "󰑖"
                lit: MusicState.repeat !== 0
                onTriggered: root.mediaAction("loop")
              }
              MiniControl {
                icon: MusicState.favorite ? "󰋑" : "󰋕"
                lit: MusicState.favorite
                favorite: true
                onTriggered: root.mediaAction("favorite")
              }
            }
          }

          Slider {
            id: miniSeekSlider
            Layout.fillWidth: true
            Layout.preferredHeight: 10
            focusPolicy: Qt.NoFocus
            from: 0
            to: root.mediaLengthKnown ? Math.max(1, root.mediaLength) : 1
            enabled: root.mediaLengthKnown
            opacity: enabled ? 1 : 0.45
            Binding on value {
              when: !miniSeekSlider.pressed
              value: root.displayPosition
            }
            background: Rectangle {
              x: miniSeekSlider.leftPadding
              y: miniSeekSlider.topPadding + miniSeekSlider.availableHeight / 2 - height / 2
              width: miniSeekSlider.availableWidth
              height: 3
              radius: 2
              color: root.track
              Rectangle {
                width: root.mediaLengthKnown ? miniSeekSlider.visualPosition * parent.width : 0
                height: parent.height
                radius: parent.radius
                color: root.accent
              }
            }
            handle: Rectangle {
              visible: root.mediaLengthKnown
              x: miniSeekSlider.leftPadding + miniSeekSlider.visualPosition * (miniSeekSlider.availableWidth - width)
              y: miniSeekSlider.topPadding + miniSeekSlider.availableHeight / 2 - height / 2
              width: 8
              height: 8
              radius: 4
              color: root.text
              scale: miniSeekSlider.pressed ? 1.2 : 1
            }
            onMoved: {
              root.interacting = true;
              root.seeking = true;
              root.displayPosition = value;
              if (!miniSeekThrottle.running) miniSeekThrottle.start();
            }
            onPressedChanged: if (!pressed) {
              miniSeekThrottle.stop();
              MusicState.seek(Math.round(value));
              root.seeking = false;
              root.interacting = false;
            }
            Timer {
              id: miniSeekThrottle
              interval: 70
              onTriggered: MusicState.seek(Math.round(miniSeekSlider.value))
            }
          }
        }
      }

      Item {
        anchors {
          left: parent.left
          right: parent.right
          top: root.panelView === "media" || root.idleView ? statusStrip.bottom : miniTransport.bottom
          bottom: parent.bottom
        }
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: root.panelView === "media" || root.idleView ? 12 : 10
        anchors.bottomMargin: 16

        RowLayout {
          anchors.fill: parent
          visible: root.panelView === "media"
          spacing: 18

          Rectangle {
            Layout.preferredWidth: 168
            Layout.fillHeight: true
            radius: 18
            color: "#000000"
            clip: true
            border.width: 1
            border.color: "#16ffffff"
            FadeArt {
              id: panelArt
              anchors.fill: parent
              source: root.mediaArt
              baseOpacity: 0.92
            }
            Text {
              anchors.centerIn: parent
              visible: panelArt.status !== Image.Ready
              text: "󰎈"
              color: "#333333"
              font.family: root.iconFont
              font.pixelSize: 52
            }
            Rectangle {
              anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
              height: parent.height * 0.4
              color: "#cc000000"
            }
            Column {
              anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 13 }
              spacing: 3
              FadeText {
                width: parent.width
                text: root.mediaTitle
                elide: Text.ElideRight
                color: "#ffffff"
                font.family: root.textFont
                font.bold: true
                font.pixelSize: 12
              }
              FadeText {
                width: parent.width
                text: root.mediaPlayer
                elide: Text.ElideRight
                color: "#a8a8a8"
                font.family: root.textFont
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1
                font.pixelSize: 8
              }
            }
            MouseArea {
              anchors.fill: parent
              z: 2
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.openCurrentAlbum()
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            FadeText {
              Layout.fillWidth: true
              text: root.mediaTitle
              elide: Text.ElideRight
              color: root.text
              font.family: root.textFont
              font.bold: true
              font.pixelSize: 19
            }
            FadeText {
              Layout.fillWidth: true
              Layout.topMargin: 2
              text: root.mediaArtist
              elide: Text.ElideRight
              color: root.subtext
              font.family: root.textFont
              font.pixelSize: 12
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openCurrentArtist()
              }
            }
            FadeText {
              Layout.fillWidth: true
              Layout.topMargin: 1
              text: root.mediaAlbumLine
              elide: Text.ElideRight
              color: root.muted
              font.family: root.textFont
              font.pixelSize: 11
            }

            Item {
              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.minimumHeight: 34
              clip: true

              Spectrum {
                anchors.centerIn: parent
                height: Math.min(46, parent.height)
                bars: 32
                barWidth: 4
                barSpacing: 4
                peak: Math.max(6, height - 8)
                floorHeight: 3
                mirrored: true
                barColor: root.text
                baseAlpha: 0.22
                gainAlpha: 0.58
                opacity: root.showLyrics ? 0 : 1
                visible: opacity > 0.01
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
              }

              Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: 3
                opacity: root.showLyrics ? 1 : 0
                visible: opacity > 0.01
                Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                Text {
                  width: parent.width
                  horizontalAlignment: Text.AlignHCenter
                  text: MusicState.lyricPrev
                  elide: Text.ElideRight
                  color: root.muted
                  font.family: root.textFont
                  font.pixelSize: 9
                }
                Text {
                  width: parent.width
                  horizontalAlignment: Text.AlignHCenter
                  text: MusicState.lyricCurrent
                  elide: Text.ElideRight
                  color: root.text
                  font.family: root.textFont
                  font.weight: Font.Bold
                  font.pixelSize: 13
                }
                Text {
                  width: parent.width
                  horizontalAlignment: Text.AlignHCenter
                  text: MusicState.lyricNext
                  elide: Text.ElideRight
                  color: root.muted
                  font.family: root.textFont
                  font.pixelSize: 9
                }
              }
            }

            Slider {
              id: seekSlider
              Layout.fillWidth: true
              Layout.preferredHeight: 18
              focusPolicy: Qt.NoFocus
              from: 0
              to: root.mediaLengthKnown ? Math.max(1, root.mediaLength) : 1
              enabled: root.mediaLengthKnown
              opacity: enabled ? 1 : 0.45
              Binding on value {
                when: !seekSlider.pressed
                value: root.displayPosition
              }
              background: Rectangle {
                x: seekSlider.leftPadding
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                width: seekSlider.availableWidth
                height: 4
                radius: 2
                color: root.track
                Rectangle {
                  width: root.mediaLengthKnown ? seekSlider.visualPosition * parent.width : 0
                  height: parent.height
                  radius: 2
                  color: root.accent
                }
              }
              handle: Rectangle {
                visible: root.mediaLengthKnown
                x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                width: 11
                height: 11
                radius: 6
                color: root.text
                scale: seekSlider.pressed ? 1.25 : 1
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
              }
              onMoved: {
                root.interacting = true;
                root.seeking = true;
                root.displayPosition = value;
                if (!seekThrottle.running) seekThrottle.start();
              }
              onPressedChanged: if (!pressed) {
                seekThrottle.stop();
                MusicState.seek(Math.round(value));
                root.seeking = false;
                root.interacting = false;
              }
              Timer {
                id: seekThrottle
                interval: 70
                onTriggered: MusicState.seek(Math.round(seekSlider.value))
              }
            }

            RowLayout {
              Layout.fillWidth: true
              Text { text: root.formatTime(root.displayPosition); color: root.muted; font.family: root.textFont; font.pixelSize: 9 }
              Item { Layout.fillWidth: true }
              Text {
                text: root.mediaLengthKnown ? root.formatTime(root.mediaLength) : "LIVE"
                color: root.muted
                font.family: root.textFont
                font.pixelSize: 9
              }
            }

            RowLayout {
              Layout.alignment: Qt.AlignHCenter
              Layout.topMargin: 10
              spacing: 24
              Repeater {
                model: [
                  { i: MusicState.shuffle ? "󰒝" : "󰒞", lit: MusicState.shuffle, command: "shuffle", large: false },
                  { i: "󰒮", lit: false, command: "previous", large: false },
                  { i: root.mediaStatus === "Playing" ? "󰏤" : "󰐊", lit: false, command: "play-pause", large: true },
                  { i: "󰒭", lit: false, command: "next", large: false },
                  { i: MusicState.repeat === 2 ? "󰑘" : "󰑖", lit: MusicState.repeat !== 0, command: "loop", large: false },
                  { i: MusicState.favorite ? "󰋑" : "󰋕", lit: MusicState.favorite, command: "favorite", large: false, heart: true }
                ]
                Text {
                  required property var modelData
                  text: modelData.i
                  color: modelData.heart && modelData.lit ? Theme.error
                    : (modelData.lit || transportHit.containsMouse ? root.text : root.subtext)
                  font.family: root.iconFont
                  font.pixelSize: modelData.large ? 30 : 21
                  scale: transportHit.pressed ? 0.84 : 1
                  Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
                  Behavior on color { ColorAnimation { duration: 140 } }
                  MouseArea {
                    id: transportHit
                    anchors.fill: parent
                    anchors.margins: -9
                    hoverEnabled: true
                    onClicked: root.mediaAction(modelData.command)
                  }
                }
              }
            }
            Item { Layout.fillHeight: true }
          }
        }

        ColumnLayout {
          anchors.fill: parent
          visible: root.panelView === "search"
          spacing: 10

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: 11
            color: root.surfaceAlt
            border.width: 1
            border.color: root.line
            TextField {
              id: searchField
              anchors.fill: parent
              leftPadding: 12
              rightPadding: 12
              placeholderText: "Search artists, albums, songs"
              color: root.text
              placeholderTextColor: root.muted
              font.family: root.textFont
              font.pixelSize: 12
              selectByMouse: true
              background: Item {}
              onTextChanged: MusicState.search(text)
            }
          }

          Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: searchColumn.implicitHeight + 8
            Column {
              id: searchColumn
              width: parent.width
              spacing: 8
              SectionLabel { text: "ARTISTS"; count: (MusicState.searchResults.artist || []).length }
              Repeater {
                model: MusicState.searchResults.artist || []
                ResultRow {
                  required property var modelData
                  title: modelData.name || "Unknown artist"
                  subtitle: modelData.albumCount ? modelData.albumCount + " albums" : "Artist"
                  badge: "ARTIST"
                  cover: ""
                  onClicked: {
                    MusicState.openArtist(modelData.id);
                    root.panelView = "artist";
                  }
                }
              }
              SectionLabel { text: "ALBUMS"; count: (MusicState.searchResults.album || []).length }
              Repeater {
                model: MusicState.searchResults.album || []
                ResultRow {
                  required property var modelData
                  title: modelData.name || "Untitled album"
                  subtitle: modelData.artist || "Unknown artist"
                  badge: modelData.year ? String(modelData.year) : "ALBUM"
                  cover: root.coverFor(modelData.coverArt)
                  onClicked: {
                    MusicState.openAlbum(modelData.id);
                    root.panelView = "album";
                  }
                }
              }
              SectionLabel { text: "SONGS"; count: (MusicState.searchResults.song || []).length }
              Repeater {
                model: MusicState.searchResults.song || []
                ResultRow {
                  required property var modelData
                  title: modelData.title || "Untitled"
                  subtitle: (modelData.artist || "Unknown artist") + (modelData.album ? " · " + modelData.album : "")
                  badge: modelData.duration ? root.formatTime(modelData.duration) : "SONG"
                  cover: root.coverFor(modelData.coverArt)
                  onClicked: {
                    MusicState.playTrack(modelData);
                    root.panelView = "media";
                  }
                }
              }
              FadeText {
                visible: !MusicState.query && !(MusicState.searchResults.song || []).length
                width: parent.width
                text: "Type to search Navidrome"
                color: root.muted
                font.family: root.textFont
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
              }
            }
          }
        }

        ColumnLayout {
          anchors.fill: parent
          visible: root.panelView === "album"
          spacing: 10
          RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            spacing: 14
            Rectangle {
              Layout.preferredWidth: 64
              Layout.preferredHeight: 64
              radius: 12
              color: root.surfaceAlt
              clip: true
              FadeArt {
                id: albumArt
                anchors.fill: parent
                source: root.coverFor(MusicState.albumData && MusicState.albumData.coverArt)
              }
              Text {
                anchors.centerIn: parent
                visible: albumArt.status !== Image.Ready
                text: "󰎈"
                color: root.muted
                font.family: root.iconFont
                font.pixelSize: 24
              }
            }
            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2
              FadeText {
                Layout.fillWidth: true
                text: MusicState.albumData ? (MusicState.albumData.name || "Album") : "Loading album…"
                color: root.text
                font.family: root.textFont
                font.bold: true
                font.pixelSize: 17
                elide: Text.ElideRight
              }
              FadeText {
                Layout.fillWidth: true
                text: MusicState.albumData ? ((MusicState.albumData.artist || "Unknown artist") + (MusicState.albumData.year ? " · " + MusicState.albumData.year : "")) : ""
                color: root.subtext
                font.family: root.textFont
                font.pixelSize: 11
                elide: Text.ElideRight
              }
              PanelChip {
                label: "PLAY ALBUM"
                onTriggered: MusicState.playAlbum()
              }
            }
          }
          Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: albumColumn.implicitHeight
            Column {
              id: albumColumn
              width: parent.width
              spacing: 5
              Repeater {
                model: MusicState.albumData && MusicState.albumData.song ? MusicState.albumData.song : []
                ResultRow {
                  required property var modelData
                  required property int index
                  title: modelData.title || "Untitled"
                  subtitle: modelData.artist || "Unknown artist"
                  badge: String(index + 1).padStart(2, "0")
                  cover: ""
                  onClicked: MusicState.playTrack(modelData)
                }
              }
            }
          }
        }

        ColumnLayout {
          anchors.fill: parent
          visible: root.panelView === "artist"
          spacing: 10
          FadeText {
            Layout.fillWidth: true
            text: MusicState.artistData ? (MusicState.artistData.name || "Artist") : "Loading artist…"
            color: root.text
            font.family: root.textFont
            font.bold: true
            font.pixelSize: 19
            elide: Text.ElideRight
          }
          Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: artistColumn.implicitHeight
            Column {
              id: artistColumn
              width: parent.width
              spacing: 5
              Repeater {
                model: MusicState.artistData && MusicState.artistData.album ? MusicState.artistData.album : []
                ResultRow {
                  required property var modelData
                  title: modelData.name || "Untitled album"
                  subtitle: modelData.year ? String(modelData.year) : "Album"
                  badge: "ALBUM"
                  cover: ""
                  onClicked: {
                    MusicState.openAlbum(modelData.id);
                    root.panelView = "album";
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  HyprlandFocusGrab {
    active: root.lockedOpen
    windows: [panel]
    onCleared: function () {
      if (root.lockedOpen) root.closePanel();
    }
  }

  component Spectrum: Row {
    id: spectrum
    property int bars: 16
    property real barWidth: 3
    property real barSpacing: 3
    property real peak: 15
    property real floorHeight: 2
    property bool mirrored: false
    property color barColor: root.text
    property bool fillWidth: false
    property real baseAlpha: 0.28
    property real gainAlpha: 0.62
    spacing: barSpacing
    opacity: root.mediaStatus === "Playing" ? 1 : 0
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
    Repeater {
      model: spectrum.bars
      Rectangle {
        required property int index
        readonly property int band: {
          if (!spectrum.mirrored) return index;
          var half = Math.floor(spectrum.bars / 2);
          return index < half ? (half - 1 - index) : (index - half);
        }
        readonly property real wave: Math.abs(Math.sin(root.visualPhase + band * 0.72))
        readonly property real amp: root.mediaStatus === "Playing" ? wave : 0
        width: spectrum.fillWidth
          ? Math.max(1, (spectrum.width - (spectrum.bars - 1) * spectrum.barSpacing) / spectrum.bars)
          : spectrum.barWidth
        height: spectrum.floorHeight + amp * spectrum.peak
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(spectrum.barColor.r, spectrum.barColor.g, spectrum.barColor.b,
                       Math.min(1, spectrum.baseAlpha + amp * spectrum.gainAlpha))
      }
    }
  }

  component FadeText: Text {
    id: fadeText
    textFormat: Text.PlainText
    opacity: 1
    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    onTextChanged: {
      fadeText.opacity = 0.35;
      fadeSettle.restart();
    }
    Timer { id: fadeSettle; interval: 1; onTriggered: fadeText.opacity = 1 }
  }

  component FadeArt: Image {
    id: fadeArt
    property real baseOpacity: 1
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    smooth: true
    opacity: baseOpacity
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    onSourceChanged: fadeArt.opacity = fadeArt.source === "" ? fadeArt.baseOpacity : fadeArt.baseOpacity * 0.35
    onStatusChanged: {
      if (fadeArt.status === Image.Ready || fadeArt.status === Image.Error)
        fadeArt.opacity = fadeArt.baseOpacity;
    }
  }

  component CompactTransportButton: Rectangle {
    id: transport
    property string icon: ""
    property bool primary: false
    signal triggered()
    width: primary ? 24 : 22
    height: 22
    radius: 7
    color: transport.primary ? root.accent : (transportHit.containsMouse ? root.chipHover : "transparent")
    scale: transportHit.pressed ? 0.86 : 1
    Behavior on color { ColorAnimation { duration: 130 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    Text {
      anchors.centerIn: parent
      text: transport.icon
      color: transport.primary ? root.accentText : root.subtext
      font.family: root.iconFont
      font.pixelSize: transport.primary ? 12 : 11
    }
    MouseArea {
      id: transportHit
      anchors.fill: parent
      hoverEnabled: true
      onClicked: transport.triggered()
    }
  }

  component MiniControl: Rectangle {
    id: control
    property string icon: ""
    property bool lit: false
    property bool favorite: false
    signal triggered()
    width: 22
    height: 22
    radius: 7
    color: miniControlHit.containsMouse ? root.chipHover : "transparent"
    scale: miniControlHit.pressed ? 0.86 : 1
    Behavior on color { ColorAnimation { duration: 130 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
    Text {
      anchors.centerIn: parent
      text: control.icon
      color: control.favorite && control.lit ? Theme.error : (control.lit ? root.accent : root.subtext)
      font.family: root.iconFont
      font.pixelSize: 11
      Behavior on color { ColorAnimation { duration: 140 } }
    }
    MouseArea {
      id: miniControlHit
      anchors.fill: parent
      hoverEnabled: true
      onClicked: control.triggered()
    }
  }

  component PanelChip: Rectangle {
    id: chip
    property string icon: ""
    property string label: ""
    property bool lit: false
    property bool danger: false
    readonly property bool dangerHover: chip.danger && chipHit.containsMouse
    signal triggered()
    implicitWidth: chip.label !== "" ? Math.max(36, chipLabel.implicitWidth + 12) : 26
    implicitHeight: 23
    radius: 8
    color: chip.lit ? root.accent
      : (chip.dangerHover ? Theme.error : (chipHit.containsMouse ? root.chipHover : root.chip))
    Behavior on color { ColorAnimation { duration: 160 } }
    scale: chipHit.pressed ? 0.9 : 1
    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
    Text {
      id: chipLabel
      anchors.centerIn: parent
      text: chip.label !== "" ? chip.label : chip.icon
      color: chip.lit ? root.accentText : (chip.dangerHover ? "#ffffff" : root.subtext)
      font.family: chip.label !== "" ? root.textFont : root.iconFont
      font.weight: chip.label !== "" ? Font.Bold : Font.Normal
      font.letterSpacing: chip.label !== "" ? 0.5 : 0
      font.pixelSize: chip.label !== "" ? 9 : 12
      Behavior on color { ColorAnimation { duration: 160 } }
    }
    MouseArea {
      id: chipHit
      anchors.fill: parent
      anchors.margins: -3
      hoverEnabled: true
      onClicked: chip.triggered()
    }
  }

  component SectionLabel: Item {
    id: sectionLabel
    property string text: ""
    property int count: 0
    width: parent ? parent.width : 0
    height: 20
    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: sectionLabel.text
      color: root.accent
      font.family: root.textFont
      font.weight: Font.Bold
      font.pixelSize: 9
      font.letterSpacing: 1
    }
    Text {
      anchors.left: parent.left
      anchors.leftMargin: 62
      anchors.verticalCenter: parent.verticalCenter
      text: sectionLabel.count > 0 ? String(sectionLabel.count) : ""
      color: root.muted
      font.family: root.textFont
      font.pixelSize: 9
    }
  }

  component ResultRow: Rectangle {
    id: result
    property string title: ""
    property string subtitle: ""
    property string badge: ""
    property string cover: ""
    signal clicked()
    width: parent ? parent.width : 0
    height: 42
    radius: 10
    color: resultHit.containsMouse ? root.chipHover : "transparent"
    border.width: 1
    border.color: resultHit.containsMouse ? root.lineStrong : "transparent"
    RowLayout {
      anchors.fill: parent
      anchors.margins: 5
      spacing: 10
      Rectangle {
        Layout.preferredWidth: 30
        Layout.preferredHeight: 30
        radius: 8
        color: root.surfaceAlt
        clip: true
        FadeArt {
          id: resultArt
          anchors.fill: parent
          source: result.cover
        }
        Text {
          anchors.centerIn: parent
          visible: resultArt.status !== Image.Ready
          text: "󰎈"
          color: root.muted
          font.family: root.iconFont
          font.pixelSize: 13
        }
      }
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0
        FadeText {
          Layout.fillWidth: true
          text: result.title
          color: root.text
          font.family: root.textFont
          font.weight: Font.DemiBold
          font.pixelSize: 11
          elide: Text.ElideRight
        }
        FadeText {
          Layout.fillWidth: true
          text: result.subtitle
          color: root.muted
          font.family: root.textFont
          font.pixelSize: 9
          elide: Text.ElideRight
        }
      }
      Text {
        text: result.badge
        color: root.subtext
        font.family: root.textFont
        font.pixelSize: 8
        font.capitalization: Font.AllUppercase
      }
    }
    MouseArea {
      id: resultHit
      anchors.fill: parent
      hoverEnabled: true
      onClicked: result.clicked()
    }
  }
}
