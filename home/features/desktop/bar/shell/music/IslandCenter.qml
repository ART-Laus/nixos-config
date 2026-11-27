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

// Project Orpheus: exactly three music surfaces.
//  1. Ambient Widget  — always present in the bar.
//  2. Player Popover  — compact player + queue preview.
//  3. Music Library   — full library, search and detail views.
// Every action is a typed call through MusicState -> orpheus-ipc -> daemon.
Item {
  id: root
  width: 320
  height: Settings.barHeight

  property bool playerOpen: false
  property bool libraryOpen: false
  property bool libraryLoaded: false
  property bool interacting: false
  property bool showLyrics: false

  readonly property bool expanded: root.playerOpen || root.libraryOpen
  readonly property string surface: root.libraryOpen ? "library" : (root.playerOpen ? "player" : "widget")

  readonly property string textFont: bricolage.name || MusicTheme.textFont
  readonly property string iconFont: MusicTheme.iconFont
  property color islandFill: MusicTheme.canvas
  property color surfaceColor: MusicTheme.surface
  property color surfaceAlt: MusicTheme.surfaceAlt
  property color text: MusicTheme.text
  property color subtext: MusicTheme.text2
  property color muted: MusicTheme.text3
  readonly property color text2: MusicTheme.text2
  readonly property color text3: MusicTheme.text3
  property color line: MusicTheme.border
  property color lineStrong: MusicTheme.borderStrong
  property color chip: MusicTheme.surfaceRaised
  property color chipHover: MusicTheme.surfaceActive
  property color accent: MusicTheme.accent
  property color accentText: MusicTheme.accentText
  property color trackColor: Qt.rgba(MusicTheme.text.r, MusicTheme.text.g, MusicTheme.text.b, 0.16)

  property real playGlow: 0
  property real ringPulse: 1
  property real visualPhase: 0
  property real displayPosition: 0
  property bool seeking: false

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
  readonly property string mediaPlayer: MusicState.backendText || "Orpheus"
  readonly property real mediaLength: Number(MusicState.duration) || 0
  readonly property bool mediaLengthKnown: mediaLength > 0
  readonly property bool idleView: mediaStatus === "Stopped"
  readonly property var queueModel: MusicState.daemonState.queue || []
  readonly property int queueIndex: Number(MusicState.daemonState.queueIndex ?? -1)

  FontLoader {
    id: bricolage
    source: "assets/BricolageGrotesque.ttf"
  }

  // Only the spectrum moves while playing; no endless glow or pulsing rings.
  NumberAnimation on visualPhase {
    running: root.mediaStatus === "Playing" && !Settings.reducedMotion
    loops: Animation.Infinite
    from: 0
    to: Math.PI * 2
    duration: 1800
    easing.type: Easing.InOutSine
    onRunningChanged: if (!running) root.visualPhase = 0
  }

  Timer {
    interval: 250
    repeat: true
    running: root.mediaStatus === "Playing" && !root.seeking
    onTriggered: {
      var limit = root.mediaLength;
      var next = root.displayPosition + 0.25;
      root.displayPosition = limit > 0 ? Math.min(limit, next) : next;
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

  function openPlayer() {
    root.libraryOpen = false;
    root.playerOpen = true;
  }

  function openLibrary() {
    root.playerOpen = false;
    root.libraryOpen = true;
    if (!root.libraryLoaded) {
      root.libraryLoaded = true;
      MusicState.setSection("home");
    }
  }

  function closeSurfaces() {
    root.playerOpen = false;
    root.libraryOpen = false;
    root.showLyrics = false;
    root.interacting = false;
  }

  function togglePlayer() {
    if (root.playerOpen) closeSurfaces();
    else openPlayer();
  }

  function mediaAction(command) {
    if (command === "play-pause") MusicState.togglePlay();
    else if (command === "play") MusicState.client.play();
    else if (command === "pause") MusicState.client.pause();
    else if (command === "previous") MusicState.previous();
    else if (command === "next") MusicState.next();
    else if (command === "stop") MusicState.client.stop();
    else if (command === "shuffle") MusicState.setShuffle(!MusicState.shuffle);
    else if (command === "loop") MusicState.cycleRepeat();
    else if (command === "favorite") MusicState.toggleFavorite();
    else if (command === "mute") MusicState.toggleMute();
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
    // Requesting inside a property binding mutates the cache and triggers a
    // binding loop. Queue it after evaluation; request() still deduplicates.
    if (!cached) {
      var coverId = String(id);
      Qt.callLater(function () { MusicState.artworkCache.request(coverId, 300); });
    }
    return cached;
  }

  function openCurrentAlbum() {
    if (!root.idleView) {
      openLibrary();
      if (root.currentAlbumId) MusicState.openAlbum(root.currentAlbumId);
      else MusicState.setSection("albums");
    } else {
      openLibrary();
    }
  }

  function openCurrentArtist() {
    if (root.idleView) { openLibrary(); return; }
    openLibrary();
    if (root.currentArtistId) MusicState.openArtist(root.currentArtistId);
    else MusicState.setSection("artists");
  }

  readonly property string currentAlbumId: MusicState.currentTrack && MusicState.currentTrack.albumId
    ? String(MusicState.currentTrack.albumId) : ""
  readonly property string currentArtistId: MusicState.currentTrack && MusicState.currentTrack.artistId
    ? String(MusicState.currentTrack.artistId) : ""

  IpcHandler {
    target: "musicCenter"
    function toggle(): void { root.togglePlayer(); }
    function state(): string { return root.surface; }
    function openLibrary(): void { root.openLibrary(); }
    function close(): void { root.closeSurfaces(); }
    function debug(): string {
      var results = MusicState.searchResults;
      var daemon = MusicState.daemonState || {};
      return JSON.stringify({
        surface: root.surface,
        ipcConnected: MusicState.ipcConnected,
        daemonSource: daemon.source || "",
        daemonRevision: daemon.revision || 0,
        status: MusicState.status,
        connectionStatus: MusicState.connectionStatus,
        lastError: MusicState.lastError,
        title: MusicState.title,
        artist: MusicState.artist,
        album: MusicState.album,
        timePos: MusicState.timePos,
        duration: MusicState.duration,
        volume: MusicState.volume,
        mute: MusicState.mute,
        favorite: MusicState.favorite,
        shuffle: MusicState.shuffle,
        repeat: MusicState.repeat,
        currentSongId: MusicState.currentSongId,
        artwork: MusicState.artwork,
        queue: root.queueModel.length,
        queueIndex: root.queueIndex,
        artworkPaths: Object.keys(MusicState.artworkCache.paths || {}).length,
        lyricsLines: (MusicState.lyricsLines || []).length,
        scanning: MusicState.scanning,
        librarySection: MusicState.librarySection,
        libraryItems: MusicState.libraryItems.length,
        searchCounts: {
          album: results.album ? results.album.length : 0,
          artist: results.artist ? results.artist.length : 0,
          song: results.song ? results.song.length : 0
        }
      });
    }
    function debugSearch(text: string): void {
      openLibrary();
      MusicState.setSection("search");
      MusicState.search(text);
    }
    function debugSeek(seconds: real): void { MusicState.seekTo(seconds); }
    function debugToggle(): void { MusicState.togglePlay(); }
    function debugFavorite(): void { MusicState.toggleFavorite(); }
    function debugOpenAlbum(): void { root.openCurrentAlbum(); }
    function debugOpenArtist(): void { root.openCurrentArtist(); }
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

  // ---- State 1: permanent ambient widget -------------------------------
  Rectangle {
    id: pill
    width: Math.max(320, Math.min(388, pillContent.implicitWidth + 44))
    height: root.height
    radius: Math.max(9, Math.floor(root.height * 0.34))
    color: root.islandFill
    border.width: 1
    border.color: root.line
    clip: true

    HoverHandler { id: pillHover }

    MouseArea {
      anchors.fill: parent
      z: -1
      acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
      onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton) MusicState.togglePlay();
        else if (mouse.button === Qt.RightButton) root.openLibrary();
        else root.togglePlayer();
      }
    }

    Rectangle {
      anchors.top: parent.top
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width * 0.65
      height: 1
      color: root.lineStrong
      opacity: root.mediaStatus === "Playing" ? 0.75 : 0.45
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
      gainAlpha: 0.18
      z: 0
    }

    RowLayout {
      id: pillContent
      z: 2
      anchors.centerIn: parent
      spacing: 10

      Item {
        visible: !root.idleView
        Layout.preferredWidth: 26
        Layout.preferredHeight: 26

        Rectangle {
          anchors.fill: parent
          radius: MusicTheme.radiusThumb
          color: root.surfaceAlt
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
            font.pixelSize: MusicTheme.iconSmall
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
          opacity: 0.55
          scale: 1.04
        }
      }

      ColumnLayout {
        visible: !root.idleView
        Layout.preferredWidth: 176
        Layout.maximumWidth: 176
        spacing: 0
        FadeText {
          Layout.fillWidth: true
          text: root.mediaTitle
          elide: Text.ElideRight
          color: root.text
          font.family: root.textFont
          font.weight: Font.DemiBold
          font.pixelSize: MusicTheme.heading
        }
        FadeText {
          Layout.fillWidth: true
          text: root.mediaArtist
          elide: Text.ElideRight
          color: root.subtext
          font.family: root.textFont
          font.pixelSize: MusicTheme.caption
        }
      }

      FadeText {
        visible: root.idleView
        text: "Carpheus Music"
        color: root.text
        font.family: root.textFont
        font.weight: Font.DemiBold
        font.pixelSize: MusicTheme.heading
      }

      Row {
        spacing: 4
        IconButton { icon: "󰒮"; tip: "Предыдущий трек"; onTriggered: root.mediaAction("previous") }
        IconButton {
          icon: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
          tip: root.mediaStatus === "Playing" ? "Пауза" : "Воспроизвести"
          primary: true
          onTriggered: root.mediaAction("play-pause")
        }
        IconButton { icon: "󰒭"; tip: "Следующий трек"; onTriggered: root.mediaAction("next") }
      }
    }

    Rectangle {
      visible: !root.idleView && root.mediaLengthKnown
      z: 3
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
      anchors.leftMargin: 14
      anchors.rightMargin: 14
      anchors.bottomMargin: 3
      height: 3
      radius: 2
      color: root.trackColor
      Rectangle {
        width: parent.width * Math.max(0, Math.min(1, root.displayPosition / Math.max(1, root.mediaLength)))
        height: parent.height
        radius: parent.radius
        color: root.accent
        Behavior on width { NumberAnimation { duration: MusicTheme.slow; easing.type: Easing.OutCubic } }
      }
    }
  }

  // ---- State 2: compact player popover ---------------------------------
  PopupWindow {
    id: playerWindow
    implicitWidth: Math.min(480, Screen.width - 40)
    implicitHeight: Math.min(520, Screen.height - 110)
    color: "transparent"
    grabFocus: root.playerOpen
    surfaceFormat.opaque: false
    visible: root.playerOpen
    anchor.item: pill
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Top
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
    anchor.margins.top: 8
    mask: Region { item: playerSurface; radius: MusicTheme.radiusPopup }
    BackgroundEffect.blurRegion: Region { item: playerSurface; radius: MusicTheme.radiusPopup }
    onClosed: if (root.playerOpen) root.closeSurfaces()

    Rectangle {
      id: playerSurface
      anchors.fill: parent
      radius: MusicTheme.radiusPopup
      color: root.islandFill
      border.width: 1
      border.color: root.line

      Item {
        id: playerKeySink
        anchors.fill: parent
        focus: root.playerOpen
        Keys.enabled: root.playerOpen
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) { root.closeSurfaces(); event.accepted = true; }
          else if (event.key === Qt.Key_Space) { root.mediaAction("play-pause"); event.accepted = true; }
          else if (event.key === Qt.Key_Left) { MusicState.seekBy(-5); event.accepted = true; }
          else if (event.key === Qt.Key_Right) { MusicState.seekBy(5); event.accepted = true; }
          else if (event.key === Qt.Key_L) { root.openLibrary(); event.accepted = true; }
        }
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: MusicTheme.pad
        spacing: MusicTheme.gapTight

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 30
          spacing: 8
          Rectangle { Layout.preferredWidth: 7; Layout.preferredHeight: 7; radius: 4; color: MusicState.connectionStatus === "connected" ? root.accent : root.muted }
          FadeText {
            Layout.fillWidth: true
            text: "PLAYER · " + root.mediaStatus.toUpperCase()
            color: root.subtext
            font.family: root.textFont
            font.weight: Font.DemiBold
            font.pixelSize: MusicTheme.caption
            font.letterSpacing: 0.8
          }
          IconButton { icon: "󰋺"; label: "Library"; tip: "Открыть библиотеку"; onTriggered: root.openLibrary() }
          IconButton {
            icon: root.showLyrics ? "󰨖" : "󰎻"
            lit: root.showLyrics
            tip: root.showLyrics ? "Скрыть текст песни" : "Показать текст песни"
            onTriggered: root.showLyrics = !root.showLyrics
          }
          IconButton { icon: "󰅖"; danger: true; tip: "Закрыть плеер"; onTriggered: root.closeSurfaces() }
        }

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: MusicTheme.coverPlayer
          spacing: 12

          Rectangle {
            Layout.preferredWidth: MusicTheme.coverPlayer
            Layout.preferredHeight: MusicTheme.coverPlayer
            radius: MusicTheme.radiusCard
            color: root.surfaceAlt
            clip: true
            border.width: 1
            border.color: root.lineStrong
            FadeArt {
              id: playerArt
              anchors.fill: parent
              source: root.mediaArt
              baseOpacity: 0.95
            }
            Text {
              anchors.centerIn: parent
              visible: playerArt.status !== Image.Ready
              text: "󰎈"
              color: root.muted
              font.family: root.iconFont
              font.pixelSize: 34
            }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.openCurrentAlbum()
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 3
            FadeText {
              Layout.fillWidth: true
              text: root.mediaTitle
              color: root.text
              font.family: root.textFont
              font.bold: true
              font.pixelSize: MusicTheme.title
              elide: Text.ElideRight
            }
            FadeText {
              Layout.fillWidth: true
              text: root.mediaArtist
              color: root.subtext
              font.family: root.textFont
              font.pixelSize: MusicTheme.body
              elide: Text.ElideRight
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openCurrentArtist()
              }
            }
            FadeText {
              Layout.fillWidth: true
              text: root.mediaAlbumLine || root.mediaPlayer
              color: root.muted
              font.family: root.textFont
              font.pixelSize: MusicTheme.caption
              elide: Text.ElideRight
            }
            RatingDots {
              Layout.topMargin: 2
              rating: Number(MusicState.currentTrack && MusicState.currentTrack.userRating) || 0
              onRated: value => MusicState.setRating(MusicState.currentSongId, value)
            }
          }
        }

        Item {
          Layout.fillWidth: true
          Layout.preferredHeight: 50
          clip: true

          Spectrum {
            anchors.centerIn: parent
            height: Math.min(48, parent.height)
            bars: 28
            barWidth: 5
            barSpacing: 5
            peak: Math.max(6, height - 8)
            floorHeight: 3
            mirrored: true
            barColor: root.text
            baseAlpha: 0.14
            gainAlpha: 0.40
            visible: !root.showLyrics
          }

          Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: 3
            visible: root.showLyrics
            FadeText {
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: MusicState.lyricPrev
              color: root.muted
              font.family: root.textFont
              font.pixelSize: MusicTheme.micro
              elide: Text.ElideRight
            }
            FadeText {
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: MusicState.lyricCurrent
              color: root.text
              font.family: root.textFont
              font.weight: Font.Bold
              font.pixelSize: MusicTheme.heading
              elide: Text.ElideRight
            }
            FadeText {
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: MusicState.lyricNext
              color: root.muted
              font.family: root.textFont
              font.pixelSize: MusicTheme.micro
              elide: Text.ElideRight
            }
          }
        }

        SeekBar { id: playerSeek; Layout.fillWidth: true }

        RowLayout {
          Layout.alignment: Qt.AlignHCenter
          Layout.fillWidth: true
          spacing: 8
          IconButton {
            icon: MusicState.shuffle ? "󰒝" : "󰒞"
            lit: MusicState.shuffle
            tip: MusicState.shuffle ? "Выключить перемешивание" : "Перемешать треки"
            onTriggered: root.mediaAction("shuffle")
          }
          IconButton { icon: "󰒮"; tip: "Предыдущий трек"; onTriggered: root.mediaAction("previous") }
          IconButton {
            icon: root.mediaStatus === "Playing" ? "󰏤" : "󰐊"
            tip: root.mediaStatus === "Playing" ? "Пауза" : "Воспроизвести"
            primary: true
            large: true
            onTriggered: root.mediaAction("play-pause")
          }
          IconButton { icon: "󰒭"; tip: "Следующий трек"; onTriggered: root.mediaAction("next") }
          IconButton {
            icon: MusicState.repeat === 2 ? "󰑘" : "󰑖"
            lit: MusicState.repeat !== 0
            tip: MusicState.repeat === 2 ? "Повтор очереди" : (MusicState.repeat === 1 ? "Повтор трека" : "Без повтора")
            onTriggered: root.mediaAction("loop")
          }
          IconButton {
            icon: MusicState.favorite ? "󰋑" : "󰋕"
            lit: MusicState.favorite
            favorite: true
            tip: MusicState.favorite ? "Убрать из избранного" : "Добавить в избранное"
            onTriggered: root.mediaAction("favorite")
          }
          IconButton {
            icon: MusicState.mute ? "󰝱" : "󰝰"
            lit: MusicState.mute
            tip: MusicState.mute ? "Включить звук" : "Выключить звук"
            onTriggered: root.mediaAction("mute")
          }
        }

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 26
          spacing: 10
          Text { text: "VOL"; color: root.muted; font.family: root.textFont; font.pixelSize: MusicTheme.caption }
          Slider {
            Layout.fillWidth: true
            from: 0
            to: 1
            value: MusicState.volume
            focusPolicy: Qt.NoFocus
            onMoved: MusicState.setVolume(value)
            background: Rectangle {
              x: parent.leftPadding
              y: parent.topPadding + parent.availableHeight / 2 - height / 2
              width: parent.availableWidth
              height: 6
              radius: 3
              color: root.trackColor
              Rectangle { width: parent.width * parent.parent.visualPosition; height: parent.height; radius: 3; color: root.accent }
            }
            handle: Rectangle {
              x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
              y: parent.topPadding + parent.availableHeight / 2 - height / 2
              width: 14
              height: 14
              radius: 7
              color: root.text
              border.width: 1
              border.color: root.lineStrong
            }
          }
        }

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true
          Layout.minimumHeight: 104
          clip: true

          FadeText {
            z: 2
            anchors.centerIn: parent
            visible: root.queueModel.length === 0
            text: "Queue is empty · add tracks from the library"
            color: root.muted
            font.family: root.textFont
            font.pixelSize: MusicTheme.caption
          }

          ColumnLayout {
            anchors.fill: parent
            spacing: MusicTheme.gapTight
            RowLayout {
              Layout.fillWidth: true
              SectionLabel { text: "QUEUE"; count: root.queueModel.length; Layout.fillWidth: true }
              IconButton { icon: "󰒝"; tip: "Перемешать очередь"; onTriggered: MusicState.shuffleQueue() }
              IconButton { icon: "󰀼"; tip: "Очистить очередь"; onTriggered: MusicState.queueClear() }
            }
            ListView {
              Layout.fillWidth: true
              Layout.fillHeight: true
              clip: true
              model: root.queueModel
              cacheBuffer: 240
              spacing: 2
              delegate: QueueRow {
                width: ListView.view.width
                title: modelData.title || "Untitled"
                subtitle: modelData.artist || ""
                badge: modelData.duration ? root.formatTime(modelData.duration) : ""
                active: modelData.id && MusicState.currentSongId && String(modelData.id) === String(MusicState.currentSongId)
                onRemove: MusicState.queueRemove(modelData && modelData.__index !== undefined ? modelData.__index : index)
                onMoveUp: { if (index > 0) MusicState.queueMove(index, index - 1); }
                onMoveDown: { if (index < ListView.view.count - 1) MusicState.queueMove(index, index + 1); }
              }
            }
          }
        }
      }
    }
  }

  // ---- State 3: full music library -------------------------------------
  PopupWindow {
    id: libraryWindow
    implicitWidth: Math.min(1040, Screen.width - 48)
    implicitHeight: Math.min(700, Screen.height - 110)
    color: "transparent"
    grabFocus: root.libraryOpen
    surfaceFormat.opaque: false
    visible: root.libraryOpen
    anchor.item: pill
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Top
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
    anchor.margins.top: 8
    mask: Region { item: librarySurface; radius: MusicTheme.radiusPopup }
    BackgroundEffect.blurRegion: Region { item: librarySurface; radius: MusicTheme.radiusPopup }
    onClosed: if (root.libraryOpen) root.closeSurfaces()

    Rectangle {
      id: librarySurface
      anchors.fill: parent
      radius: MusicTheme.radiusPopup
      color: root.islandFill
      border.width: 1
      border.color: root.line

      Item {
        id: libraryKeySink
        anchors.fill: parent
        focus: root.libraryOpen
        Keys.enabled: root.libraryOpen
        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) {
            if (MusicState.view !== MusicState.librarySection) MusicState.back();
            else root.closeSurfaces();
            event.accepted = true;
          } else if (event.key === Qt.Key_Space) {
            root.mediaAction("play-pause");
            event.accepted = true;
          } else if (event.key === Qt.Key_P) {
            root.openPlayer();
            event.accepted = true;
          }
        }
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: MusicTheme.pad
        spacing: MusicTheme.gapTight

        Rectangle {
          Layout.preferredWidth: MusicTheme.navWidth
          Layout.fillHeight: true
          radius: MusicTheme.radiusCard
          color: root.surfaceAlt
          border.width: 1
          border.color: root.line

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: MusicTheme.gapTight
            FadeText {
              Layout.preferredHeight: 38
              text: "ORPHEUS"
              color: root.accent
              font.family: root.textFont
              font.bold: true
              font.pixelSize: MusicTheme.hero
              font.letterSpacing: 1.5
            }
            Repeater {
              model: [
                { id: "home", icon: "󰋺", label: "Home" },
                { id: "artists", icon: "󰚢", label: "Artists" },
                { id: "albums", icon: "󰎈", label: "Albums" },
                { id: "tracks", icon: "󰎆", label: "Tracks" },
                { id: "genres", icon: "󰘨", label: "Genres" },
                { id: "playlists", icon: "󰋑", label: "Playlists" },
                { id: "favorites", icon: "󰋑", label: "Favorites" },
                { id: "search", icon: "󰍉", label: "Search" }
              ]
              SectionButton {
                Layout.fillWidth: true
                required property var modelData
                icon: modelData.icon
                label: modelData.label
                lit: MusicState.librarySection === modelData.id && MusicState.view !== "album" && MusicState.view !== "artist" && MusicState.view !== "playlist" && MusicState.view !== "genre"
                onTriggered: {
                  MusicState.setSection(modelData.id);
                  if (modelData.id === "search") Qt.callLater(function() { librarySearch.forceActiveFocus(); });
                }
              }
            }
            Item { Layout.fillHeight: true }
            FadeText {
              Layout.fillWidth: true
              text: MusicState.connectionText
              color: root.muted
              font.family: root.textFont
              font.pixelSize: MusicTheme.caption
              wrapMode: Text.Wrap
            }
            MiniChip { label: "PLAYER"; icon: "󰐊"; Layout.fillWidth: true; onTriggered: root.openPlayer() }
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 10

          RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            spacing: 8
            Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: MusicTheme.controlHeight
              radius: MusicTheme.radiusControl
              color: root.surfaceAlt
              border.width: 1
              border.color: librarySearch.activeFocus ? MusicTheme.borderStrong : root.line
              Behavior on border.color { ColorAnimation { duration: MusicTheme.fast } }
              Text {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "󰍉"
                color: root.muted
                font.family: root.iconFont
                font.pixelSize: MusicTheme.icon
              }
              TextField {
                id: librarySearch
                anchors.fill: parent
                leftPadding: 42
                rightPadding: 14
                placeholderText: "Search artists, albums, songs"
                color: root.text
                placeholderTextColor: root.muted
                font.family: root.textFont
                font.pixelSize: MusicTheme.body
                selectByMouse: true
                background: Item {}
                onTextChanged: {
                  if (text.trim()) {
                    MusicState.librarySection = "search";
                    MusicState.view = "search";
                  }
                  MusicState.search(text);
                }
              }
            }
            MiniChip {
              label: "RANDOM"
              icon: "󰒝"
              onTriggered: MusicState.random()
            }
            MiniChip {
              label: MusicState.scanning ? "SCANNING" : "SCAN"
              icon: "󰑓"
              onTriggered: MusicState.quickScan()
            }
            MiniChip {
              icon: "󰅖"
              danger: true
              onTriggered: root.closeSurfaces()
            }
          }

          Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Home
            ColumnLayout {
              anchors.fill: parent
              visible: MusicState.view === "home"
              spacing: 10
              RowLayout {
                Layout.fillWidth: true
                SectionLabel { text: "HOME"; count: 0; Layout.fillWidth: true }
                FadeText {
                  text: (MusicState.libraryData.recentAlbums || []).length + " albums · " +
                        (MusicState.libraryData.randomSongs || []).length + " songs"
                  color: root.muted
                  font.family: root.textFont
                  font.pixelSize: MusicTheme.caption
                }
              }
              Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentHeight: homeColumn.implicitHeight + 8
                Column {
                  id: homeColumn
                  width: parent.width
                  spacing: 8
                  SectionLabel { text: "RECENT ALBUMS"; count: (MusicState.libraryData.recentAlbums || []).length }
                  Flow {
                    width: parent.width
                    spacing: 8
                    Repeater {
                      model: MusicState.libraryData.recentAlbums || []
                      Tile {
                        required property var modelData
                        title: modelData.name || "Album"
                        subtitle: modelData.artist || ""
                        cover: root.coverFor(modelData.coverArt)
                        onTriggered: MusicState.openAlbum(modelData.id)
                      }
                    }
                  }
                  SectionLabel { text: "SHUFFLE SEEDS"; count: (MusicState.libraryData.randomSongs || []).length }
                  ListView {
                    width: parent.width
                    height: Math.min(180, Math.max(96, count * 38))
                    model: MusicState.libraryData.randomSongs || []
                    interactive: false
                    cacheBuffer: 200
                    delegate: ResultRow {
                      required property var modelData
                      width: ListView.view.width
                      title: modelData.title || "Untitled"
                      subtitle: modelData.artist || ""
                      badge: modelData.duration ? root.formatTime(modelData.duration) : "SONG"
                      cover: root.coverFor(modelData.coverArt)
                      favorite: MusicState.isStarred(modelData)
                      onTriggered: MusicState.playTrack(modelData)
                      onAdd: MusicState.queueAdd([modelData], false)
                      onNext: MusicState.queueAdd([modelData], true)
                      onFavoriteToggled: MusicState.setFavorite(modelData.id, !favorite)
                    }
                  }
                  SectionLabel { text: "GENRES"; count: (MusicState.libraryData.genres || []).length }
                  Flow {
                    width: parent.width
                    spacing: 6
                    Repeater {
                      model: (MusicState.libraryData.genres || []).slice(0, 24)
                      MiniChip {
                        required property var modelData
                        label: modelData.name || "Genre"
                        onTriggered: MusicState.openGenre(modelData.name)
                      }
                    }
                  }
                }
              }
            }

            // Section lists (virtualized + paginated)
            ColumnLayout {
              anchors.fill: parent
              visible: ["artists", "albums", "tracks", "genres", "playlists", "favorites"].indexOf(MusicState.view) >= 0
              spacing: 8
              RowLayout {
                Layout.fillWidth: true
                SectionLabel {
                  text: MusicState.librarySection.toUpperCase()
                  count: MusicState.libraryItems.length
                  Layout.fillWidth: true
                }
                FadeText {
                  visible: MusicState.libraryLoading
                  text: "Loading…"
                  color: root.muted
                  font.family: root.textFont
                  font.pixelSize: MusicTheme.caption
                }
              }
              FadeText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !MusicState.libraryLoading && MusicState.libraryItems.length === 0
                text: "Nothing here yet"
                color: root.muted
                font.family: root.textFont
                font.pixelSize: MusicTheme.body
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }
              ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: MusicState.libraryItems || []
                cacheBuffer: 420
                spacing: 4
                onMovementEnded: if (atYEnd) MusicState.loadMore()
                delegate: ResultRow {
                  required property var modelData
                  required property int index
                  width: ListView.view.width
                  title: modelData.name || modelData.title || "Untitled"
                  subtitle: modelData.artist || modelData.album || (modelData.songCount ? modelData.songCount + " tracks" : "")
                  badge: modelData.year ? String(modelData.year) : (modelData.duration ? root.formatTime(modelData.duration) : "")
                  cover: root.coverFor(modelData.coverArt)
                  favorite: MusicState.isStarred(modelData)
                  onTriggered: {
                    if (modelData.id && modelData.songCount !== undefined) MusicState.openAlbum(modelData.id);
                    else if (modelData.id && modelData.albumCount !== undefined) MusicState.openArtist(modelData.id);
                    else if (modelData.name && MusicState.librarySection === "genres") MusicState.openGenre(modelData.name);
                    else if (modelData.id && MusicState.librarySection === "playlists") MusicState.openPlaylist(modelData.id);
                    else MusicState.playTrack(modelData);
                  }
                  onAdd: MusicState.queueAdd([modelData], false)
                  onNext: MusicState.queueAdd([modelData], true)
                  onFavoriteToggled: MusicState.setFavorite(modelData.id, !favorite)
                }
              }
              Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: MusicState.librarySection === "playlists" ? 46 : 0
                visible: Layout.preferredHeight > 0
                radius: MusicTheme.radiusControl
                color: root.surfaceAlt
                border.width: 1
                border.color: root.line
                RowLayout {
                  anchors.fill: parent
                  anchors.margins: 8
                  TextField {
                    id: newPlaylist
                    Layout.fillWidth: true
                    placeholderText: "New playlist name"
                    color: root.text
                    placeholderTextColor: root.muted
                    font.family: root.textFont
                    font.pixelSize: MusicTheme.bodyMinor
                    background: Item {}
                  }
                  MiniChip {
                    label: "CREATE"
                    onTriggered: {
                      if (newPlaylist.text.trim()) {
                        MusicState.createPlaylist(newPlaylist.text.trim());
                        newPlaylist.text = "";
                      }
                    }
                  }
                }
              }
            }

            // Search
            ColumnLayout {
              anchors.fill: parent
              visible: MusicState.view === "search"
              spacing: 8
              Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentHeight: searchColumn.implicitHeight + 8
                Column {
                  id: searchColumn
                  width: parent.width
                  spacing: 6
                  SectionLabel { text: "ARTISTS"; count: (MusicState.searchResults.artist || []).length }
                  Repeater {
                    model: MusicState.searchResults.artist || []
                    ResultRow {
                      required property var modelData
                      width: ListView.view ? ListView.view.width : parent.width
                      title: modelData.name || "Unknown artist"
                      subtitle: modelData.albumCount ? modelData.albumCount + " albums" : "Artist"
                      badge: "ARTIST"
                      cover: ""
                      onTriggered: MusicState.openArtist(modelData.id)
                      onAdd: {}
                      onNext: {}
                      onFavoriteToggled: {}
                    }
                  }
                  SectionLabel { text: "ALBUMS"; count: (MusicState.searchResults.album || []).length }
                  Repeater {
                    model: MusicState.searchResults.album || []
                    ResultRow {
                      required property var modelData
                      width: ListView.view ? ListView.view.width : parent.width
                      title: modelData.name || "Untitled album"
                      subtitle: modelData.artist || "Unknown artist"
                      badge: modelData.year ? String(modelData.year) : "ALBUM"
                      cover: root.coverFor(modelData.coverArt)
                      favorite: MusicState.isStarred(modelData)
                      onTriggered: MusicState.openAlbum(modelData.id)
                      onAdd: MusicState.queueAdd([modelData], false)
                      onNext: MusicState.queueAdd([modelData], true)
                      onFavoriteToggled: MusicState.setFavorite(modelData.id, !favorite)
                    }
                  }
                  SectionLabel { text: "SONGS"; count: (MusicState.searchResults.song || []).length }
                  Repeater {
                    model: MusicState.searchResults.song || []
                    ResultRow {
                      required property var modelData
                      width: ListView.view ? ListView.view.width : parent.width
                      title: modelData.title || "Untitled"
                      subtitle: (modelData.artist || "Unknown artist") + (modelData.album ? " · " + modelData.album : "")
                      badge: modelData.duration ? root.formatTime(modelData.duration) : "SONG"
                      cover: root.coverFor(modelData.coverArt)
                      favorite: MusicState.isStarred(modelData)
                      onTriggered: MusicState.playTrack(modelData)
                      onAdd: MusicState.queueAdd([modelData], false)
                      onNext: MusicState.queueAdd([modelData], true)
                      onFavoriteToggled: MusicState.setFavorite(modelData.id, !favorite)
                    }
                  }
                  FadeText {
                    visible: !MusicState.query.trim() && !(MusicState.searchResults.song || []).length
                    width: parent.width
                    text: "Type to search the entire Navidrome library"
                    color: root.muted
                    font.family: root.textFont
                    font.pixelSize: MusicTheme.bodyMinor
                    horizontalAlignment: Text.AlignHCenter
                  }
                  FadeText {
                    visible: MusicState.query.trim() &&
                      !(MusicState.searchResults.artist || []).length &&
                      !(MusicState.searchResults.album || []).length &&
                      !(MusicState.searchResults.song || []).length
                    width: parent.width
                    text: "No matches for “" + MusicState.query.trim() + "”"
                    color: root.muted
                    font.family: root.textFont
                    font.pixelSize: MusicTheme.bodyMinor
                    horizontalAlignment: Text.AlignHCenter
                  }
                }
              }
            }

            // Album detail
            DetailView {
              visible: MusicState.view === "album"
              heading: MusicState.albumData ? (MusicState.albumData.name || "Album") : "Loading album…"
              subheading: MusicState.albumData ? ((MusicState.albumData.artist || "Unknown artist") + (MusicState.albumData.year ? " · " + MusicState.albumData.year : "")) : ""
              cover: root.coverFor(MusicState.albumData && MusicState.albumData.coverArt)
              model: (MusicState.albumData && MusicState.albumData.song) || []
              onPlayAll: MusicState.playAlbum()
              onBack: MusicState.back()
              onPlay: function (modelData) { MusicState.playTrack(modelData) }
              onAdd: function (modelData) { MusicState.queueAdd([modelData], false) }
              onNext: function (modelData) { MusicState.queueAdd([modelData], true) }
              onFavorite: function (modelData) { MusicState.setFavorite(modelData.id, !modelData.starred) }
            }

            // Artist detail
            DetailView {
              visible: MusicState.view === "artist"
              heading: MusicState.artistData ? (MusicState.artistData.name || "Artist") : "Loading artist…"
              subheading: "Albums"
              cover: root.coverFor(MusicState.artistData && MusicState.artistData.coverArt)
              model: (MusicState.artistData && MusicState.artistData.album) || []
              onPlayAll: {}
              onBack: MusicState.back()
              onPlay: function (modelData) { MusicState.openAlbum(modelData.id) }
              onAdd: function (modelData) {}
              onNext: function (modelData) {}
              onFavorite: function (modelData) {}
            }

            // Playlist detail
            DetailView {
              visible: MusicState.view === "playlist"
              heading: MusicState.playlistData ? (MusicState.playlistData.name || "Playlist") : "Loading playlist…"
              subheading: (MusicState.playlistData && MusicState.playlistData.songCount ? MusicState.playlistData.songCount + " tracks" : "Playlist")
              cover: ""
              model: (MusicState.playlistData && MusicState.playlistData.song) || []
              onPlayAll: MusicState.playPlaylist()
              onBack: MusicState.back()
              onPlay: function (modelData) { MusicState.playTrack(modelData) }
              onAdd: function (modelData) { MusicState.queueAdd([modelData], false) }
              onNext: function (modelData) { MusicState.queueAdd([modelData], true) }
              onFavorite: function (modelData) { MusicState.setFavorite(modelData.id, !modelData.starred) }
            }

            // Genre detail
            DetailView {
              visible: MusicState.view === "genre"
              heading: MusicState.libraryData.genre || "Genre"
              subheading: "Songs"
              cover: ""
              model: MusicState.libraryItems || []
              onPlayAll: MusicState.playQueue(MusicState.libraryItems, 0)
              onBack: MusicState.back()
              onPlay: function (modelData) { MusicState.playTrack(modelData) }
              onAdd: function (modelData) { MusicState.queueAdd([modelData], false) }
              onNext: function (modelData) { MusicState.queueAdd([modelData], true) }
              onFavorite: function (modelData) { MusicState.setFavorite(modelData.id, !modelData.starred) }
            }
          }
        }
      }
    }
  }

  HyprlandFocusGrab {
    active: root.expanded
    windows: [playerWindow, libraryWindow]
    onCleared: function () {
      if (root.expanded) root.closeSurfaces();
    }
  }

  // ---- shared components ------------------------------------------------
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
    opacity: root.mediaStatus === "Playing" && !Settings.reducedMotion ? 1 : 0
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: MusicTheme.duration; easing.type: Easing.OutCubic } }
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
        readonly property real amp: root.mediaStatus === "Playing" && !Settings.reducedMotion ? wave : 0
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
    Behavior on opacity { NumberAnimation { duration: MusicTheme.duration; easing.type: Easing.OutCubic } }
    onTextChanged: {
      if (Settings.reducedMotion) return;
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
    Behavior on opacity { NumberAnimation { duration: MusicTheme.duration; easing.type: Easing.OutCubic } }
    onSourceChanged: {
      if (Settings.reducedMotion) return;
      fadeArt.opacity = fadeArt.source === "" ? fadeArt.baseOpacity : fadeArt.baseOpacity * 0.35;
    }
    onStatusChanged: {
      if (fadeArt.status === Image.Ready || fadeArt.status === Image.Error)
        fadeArt.opacity = fadeArt.baseOpacity;
    }
  }

  component IconButton: Rectangle {
    id: button
    property string icon: ""
    property string label: ""
    property bool primary: false
    property bool lit: false
    property bool favorite: false
    property bool danger: false
    property bool large: false
    property string tip: ""
    property bool tipAbove: false
    property bool tipShown: false
    signal triggered()

    Timer {
      id: tipTimer
      interval: 450
      onTriggered: button.tipShown = true
    }
    onTipChanged: {
      button.tipShown = false;
      if (buttonHit.containsMouse) tipTimer.restart();
    }

    Rectangle {
      id: tipBox
      visible: button.tipShown && button.tip !== ""
      z: 20
      width: Math.min(300, tipText.implicitWidth + 20)
      height: 32
      radius: MusicTheme.radiusControl
      color: Qt.rgba(MusicTheme.surfaceAlt.r, MusicTheme.surfaceAlt.g, MusicTheme.surfaceAlt.b, 1)
      border.width: 1
      border.color: Qt.rgba(MusicTheme.border.r, MusicTheme.border.g, MusicTheme.border.b, 1)
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: button.tipAbove ? undefined : parent.bottom
      anchors.topMargin: button.tipAbove ? 0 : 6
      anchors.bottom: button.tipAbove ? parent.top : undefined
      anchors.bottomMargin: button.tipAbove ? 6 : 0
      Text {
        id: tipText
        anchors.centerIn: parent
        width: tipBox.width - 20
        text: button.tip
        color: root.text
        font.family: root.textFont
        font.pixelSize: MusicTheme.caption
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
      }
    }
    implicitWidth: button.label !== ""
      ? Math.max(MusicTheme.buttonSize, buttonLabel.implicitWidth + 22)
      : (button.large ? MusicTheme.buttonLarge : MusicTheme.buttonSize)
    implicitHeight: button.large ? MusicTheme.buttonLarge : MusicTheme.buttonSize
    z: button.tipShown ? 20 : 0
    radius: MusicTheme.radiusControl
    color: button.primary ? root.accent
      : (button.lit ? root.chipHover
      : (button.danger && buttonHit.containsMouse ? Theme.error
      : (buttonHit.containsMouse ? root.chipHover : "transparent")))
    border.width: button.lit && !button.primary ? 1 : 0
    border.color: root.lineStrong
    scale: buttonHit.pressed ? 0.94 : 1
    Behavior on color { ColorAnimation { duration: MusicTheme.fast } }
    Behavior on scale { NumberAnimation { duration: MusicTheme.fast; easing.type: Easing.OutCubic } }
    Row {
      anchors.centerIn: parent
      spacing: MusicTheme.gapTight
      Text {
        id: buttonIcon
        visible: button.icon !== ""
        text: button.icon
        color: button.primary ? root.accentText
          : (button.favorite && button.lit ? Theme.error
          : (button.lit ? root.accent : (button.danger && buttonHit.containsMouse ? Theme.text : root.subtext)))
        font.family: root.iconFont
        font.pixelSize: button.large ? MusicTheme.iconLarge : MusicTheme.icon
      }
      Text {
        id: buttonLabel
        visible: button.label !== ""
        text: button.label
        color: button.primary ? root.accentText : root.text2
        font.family: root.textFont
        font.pixelSize: MusicTheme.micro
        font.capitalization: Font.AllUppercase
      }
    }
    MouseArea {
      id: buttonHit
      anchors.fill: parent
      anchors.margins: -2
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: if (button.tip !== "") tipTimer.restart()
      onExited: { tipTimer.stop(); button.tipShown = false; }
      onClicked: { button.tipShown = false; button.triggered(); }
    }
  }

  component MiniChip: Rectangle {
    id: chip
    property string icon: ""
    property string label: ""
    property bool danger: false
    signal triggered()
    implicitWidth: Math.max(MusicTheme.buttonSize, chipLabel.implicitWidth + 28)
    implicitHeight: MusicTheme.controlHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: MusicTheme.radiusControl
    color: chipHit.containsMouse ? root.chipHover : root.chip
    border.width: 1
    border.color: root.line
    Row {
      anchors.centerIn: parent
      spacing: MusicTheme.gapTight
      Text {
        visible: chip.icon !== ""
        text: chip.icon
        color: chip.danger && chipHit.containsMouse ? Theme.error : root.accent
        font.family: root.iconFont
        font.pixelSize: MusicTheme.iconSmall
      }
      Text {
        id: chipLabel
        text: chip.label
        color: chip.danger && chipHit.containsMouse ? Theme.error : root.text
        font.family: root.textFont
        font.pixelSize: MusicTheme.caption
        font.capitalization: Font.AllUppercase
      }
    }
    MouseArea {
      id: chipHit
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: chip.triggered()
    }
  }

  component SectionButton: Rectangle {
    id: section
    property string icon: ""
    property string label: ""
    property bool lit: false
    signal triggered()
    implicitHeight: MusicTheme.navHeight
    radius: MusicTheme.radiusControl
    color: section.lit ? root.chipHover
      : (sectionHit.containsMouse ? MusicTheme.surfaceHover : "transparent")
    border.width: section.lit ? 1 : 0
    border.color: root.lineStrong
    RowLayout {
      anchors.fill: parent
      anchors.margins: MusicTheme.padTight
      spacing: MusicTheme.gapTight
      Text {
        text: section.icon
        color: section.lit ? root.accent : root.text2
        font.family: root.iconFont
        font.pixelSize: MusicTheme.icon
      }
      FadeText {
        Layout.fillWidth: true
        text: section.label
        color: section.lit ? root.text : root.text2
        font.family: root.textFont
        font.pixelSize: MusicTheme.body
      }
    }
    MouseArea {
      id: sectionHit
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: section.triggered()
    }
  }

  component SectionLabel: Item {
    id: sectionLabel
    property string text: ""
    property int count: 0
    width: parent ? parent.width : 0
    Layout.fillWidth: true
    Layout.preferredHeight: 26
    implicitHeight: 26
    height: 26
    Text {
      id: sectionTitle
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: sectionLabel.text
      color: root.accent
      font.family: root.textFont
      font.weight: Font.Bold
      font.pixelSize: MusicTheme.section
      font.letterSpacing: 0.6
    }
    Text {
      anchors.left: parent.left
      anchors.leftMargin: sectionTitle.implicitWidth + 10
      anchors.verticalCenter: parent.verticalCenter
      text: sectionLabel.count > 0 ? String(sectionLabel.count) : ""
      color: root.text3
      font.family: root.textFont
      font.pixelSize: MusicTheme.caption
    }
  }

  component Tile: Rectangle {
    id: tile
    property string title: ""
    property string subtitle: ""
    property string cover: ""
    signal triggered()
    width: MusicTheme.tileWidth
    height: MusicTheme.tileHeight
    radius: MusicTheme.radiusCard
    color: root.surfaceAlt
    border.width: tileHit.containsMouse ? 1 : 0
    border.color: root.lineStrong
    clip: true
    scale: tileHit.containsMouse ? 1.02 : 1
    Behavior on color { ColorAnimation { duration: MusicTheme.fast } }
    Behavior on scale { NumberAnimation { duration: MusicTheme.fast; easing.type: Easing.OutCubic } }
    FadeArt {
      id: tileArt
      anchors { left: parent.left; right: parent.right; top: parent.top }
      height: MusicTheme.tileWidth
      source: tile.cover
    }
    Text {
      anchors.centerIn: tileArt
      visible: tileArt.status !== Image.Ready
      text: "󰎈"
      color: root.text3
      font.family: root.iconFont
      font.pixelSize: MusicTheme.iconLarge
    }
    Column {
      anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
      spacing: 2
      FadeText {
        width: parent.width
        text: tile.title
        color: root.text
        font.family: root.textFont
        font.pixelSize: MusicTheme.body
        font.weight: Font.DemiBold
        elide: Text.ElideRight
        ToolTip.text: tile.title + (tile.subtitle ? " — " + tile.subtitle : "")
        ToolTip.visible: tileHit.containsMouse
        ToolTip.delay: 450
        ToolTip.timeout: 2200
      }
      FadeText {
        width: parent.width
        text: tile.subtitle
        color: root.text3
        font.family: root.textFont
        font.pixelSize: MusicTheme.caption
        elide: Text.ElideRight
      }
    }
    MouseArea {
      id: tileHit
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: tile.triggered()
    }
  }

  component ResultRow: Rectangle {
    id: row
    property string title: ""
    property string subtitle: ""
    property string badge: ""
    property string cover: ""
    property bool favorite: false
    signal triggered()
    signal add()
    signal next()
    signal favoriteToggled()
    width: parent ? parent.width : 0
    height: MusicTheme.rowHeight
    radius: MusicTheme.radiusControl
    color: rowHit.containsMouse ? MusicTheme.surfaceHover : "transparent"
    border.width: rowHit.containsMouse ? 1 : 0
    border.color: root.lineStrong
    Behavior on color { ColorAnimation { duration: MusicTheme.fast } }
    RowLayout {
      anchors.fill: parent
      anchors.margins: MusicTheme.padTight
      spacing: MusicTheme.gapTight
      Rectangle {
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: MusicTheme.radiusThumb
        color: root.surfaceAlt
        clip: true
        FadeArt {
          id: resultArt
          anchors.fill: parent
          source: row.cover
        }
        Text {
          anchors.centerIn: parent
          visible: resultArt.status !== Image.Ready
          text: "󰎈"
          color: root.text3
          font.family: root.iconFont
          font.pixelSize: MusicTheme.icon
        }
      }
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        FadeText {
          Layout.fillWidth: true
          text: row.title
          color: root.text
          font.family: root.textFont
          font.weight: Font.DemiBold
          font.pixelSize: MusicTheme.body
          elide: Text.ElideRight
        }
        FadeText {
          Layout.fillWidth: true
          text: row.subtitle
          color: root.text2
          font.family: root.textFont
          font.pixelSize: MusicTheme.caption
          elide: Text.ElideRight
        }
      }
      Text {
        visible: !rowHit.containsMouse
        text: row.badge
        color: root.text3
        font.family: root.textFont
        font.pixelSize: MusicTheme.caption
        font.capitalization: Font.AllUppercase
      }
      Row {
        z: 2
        spacing: 2
        visible: rowHit.containsMouse
        IconButton { icon: "󰐊"; onTriggered: row.triggered() }
        IconButton { icon: "󰐼"; onTriggered: row.add() }
        IconButton { icon: "󰒭"; onTriggered: row.next() }
        IconButton {
          icon: row.favorite ? "󰋑" : "󰋕"
          lit: row.favorite
          favorite: true
          onTriggered: row.favoriteToggled()
        }
      }
    }
    Menu {
      id: rowMenu
      MenuItem { text: "Play"; onTriggered: row.triggered() }
      MenuItem { text: "Add to queue"; onTriggered: row.add() }
      MenuItem { text: "Play next"; onTriggered: row.next() }
      MenuItem {
        text: row.favorite ? "Remove favorite" : "Add favorite"
        onTriggered: row.favoriteToggled()
      }
    }
    MouseArea {
      id: rowHit
      z: 1
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) row.triggered();
        else rowMenu.popup(mouseX, mouseY);
      }
    }
  }

  component QueueRow: Rectangle {
    id: queueRow
    property string title: ""
    property string subtitle: ""
    property string badge: ""
    property bool active: false
    signal remove()
    signal moveUp()
    signal moveDown()
    height: MusicTheme.queueRowHeight
    radius: MusicTheme.radiusControl
    color: queueRow.active ? root.chipHover
      : (queueHit.containsMouse ? MusicTheme.surfaceHover : "transparent")
    border.width: queueRow.active ? 1 : 0
    border.color: root.lineStrong
    RowLayout {
      anchors.fill: parent
      anchors.margins: 8
      spacing: MusicTheme.gapTight
      Text {
        text: queueRow.active ? "󰐊" : "󰎆"
        color: queueRow.active ? root.accent : root.text3
        font.family: root.iconFont
        font.pixelSize: MusicTheme.iconSmall
      }
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        FadeText {
          Layout.fillWidth: true
          text: queueRow.title
          color: queueRow.active ? root.text : root.text2
          font.family: root.textFont
          font.pixelSize: MusicTheme.body
          elide: Text.ElideRight
        }
        FadeText {
          Layout.fillWidth: true
          visible: queueRow.subtitle !== ""
          text: queueRow.subtitle
          color: root.text3
          font.family: root.textFont
          font.pixelSize: MusicTheme.micro
          elide: Text.ElideRight
        }
      }
      Text {
        visible: queueRow.badge !== ""
        text: queueRow.badge
        color: root.text3
        font.family: root.textFont
        font.pixelSize: MusicTheme.micro
      }
      IconButton { icon: "󰒮"; tip: "Переместить выше"; tipAbove: true; onTriggered: queueRow.moveUp() }
      IconButton { icon: "󰒭"; tip: "Переместить ниже"; tipAbove: true; onTriggered: queueRow.moveDown() }
      IconButton { icon: "󰀼"; tip: "Убрать из очереди"; tipAbove: true; onTriggered: queueRow.remove() }
    }
    Menu {
      id: queueMenu
      MenuItem { text: "Move up"; onTriggered: queueRow.moveUp() }
      MenuItem { text: "Move down"; onTriggered: queueRow.moveDown() }
      MenuItem { text: "Remove"; onTriggered: queueRow.remove() }
    }
    MouseArea {
      id: queueHit
      z: 1
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: mouse => {
        if (mouse.button === Qt.RightButton) queueMenu.popup(mouseX, mouseY);
      }
    }
  }

  component RatingDots: Row {
    id: rating
    property int rating: 0
    signal rated(int value)
    spacing: MusicTheme.gapTight
    Repeater {
      model: 5
      Text {
        required property int index
        text: index < rating.rating ? "󰋑" : "󰋕"
        color: index < rating.rating ? Theme.error : root.text3
        font.family: root.iconFont
        font.pixelSize: MusicTheme.iconSmall
        MouseArea {
          anchors.fill: parent
          anchors.margins: -2
          onClicked: rating.rated(index + 1)
        }
      }
    }
  }

  component SeekBar: ColumnLayout {
    id: seekBar
    Layout.fillWidth: true
    spacing: 4
    Slider {
      id: slider
      Layout.fillWidth: true
      Layout.preferredHeight: 20
      focusPolicy: Qt.NoFocus
      from: 0
      to: root.mediaLengthKnown ? Math.max(1, root.mediaLength) : 1
      enabled: root.mediaLengthKnown
      opacity: enabled ? 1 : 0.45
      Binding on value {
        when: !slider.pressed
        value: root.displayPosition
      }
      background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 6
        radius: 3
        color: root.trackColor
        Rectangle {
          width: root.mediaLengthKnown ? slider.visualPosition * parent.width : 0
          height: parent.height
          radius: 3
          color: root.accent
        }
      }
      handle: Rectangle {
        visible: root.mediaLengthKnown
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 14
        height: 14
        radius: 7
        color: slider.pressed ? root.accent : root.text
        border.width: 1
        border.color: root.lineStrong
      }
      onMoved: {
        root.interacting = true;
        root.seeking = true;
        root.displayPosition = value;
        if (!throttle.running) throttle.start();
      }
      onPressedChanged: if (!pressed) {
        throttle.stop();
        MusicState.seekTo(Math.round(value));
        root.seeking = false;
        root.interacting = false;
      }
      Timer {
        id: throttle
        interval: 70
        onTriggered: MusicState.seekTo(Math.round(slider.value))
      }
    }
    RowLayout {
      Layout.fillWidth: true
      Text { text: root.formatTime(root.displayPosition); color: root.text3; font.family: root.textFont; font.pixelSize: MusicTheme.caption }
      Item { Layout.fillWidth: true }
      Text {
        text: root.mediaLengthKnown ? root.formatTime(root.mediaLength) : "LIVE"
        color: root.text3
        font.family: root.textFont
        font.pixelSize: MusicTheme.caption
      }
    }
  }

  component DetailView: ColumnLayout {
    id: detail
    anchors.fill: parent
    property string heading: ""
    property string subheading: ""
    property string cover: ""
    property var model: []
    signal playAll()
    signal back()
    signal play(var modelData)
    signal add(var modelData)
    signal next(var modelData)
    signal favorite(var modelData)
    spacing: MusicTheme.gapTight

    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 92
      spacing: MusicTheme.gapTight
      Rectangle {
        Layout.preferredWidth: 92
        Layout.preferredHeight: 92
        radius: MusicTheme.radiusCard
        color: root.surfaceAlt
        clip: true
        border.width: 1
        border.color: root.line
        FadeArt {
          id: detailArt
          anchors.fill: parent
          source: detail.cover
        }
        Text {
          anchors.centerIn: parent
          visible: detailArt.status !== Image.Ready
          text: "󰎈"
          color: root.text3
          font.family: root.iconFont
          font.pixelSize: MusicTheme.iconLarge
        }
      }
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 3
        FadeText {
          Layout.fillWidth: true
          text: detail.heading
          color: root.text
          font.family: root.textFont
          font.bold: true
          font.pixelSize: MusicTheme.title
          elide: Text.ElideRight
        }
        FadeText {
          Layout.fillWidth: true
          text: detail.subheading
          color: root.text2
          font.family: root.textFont
          font.pixelSize: MusicTheme.bodyMinor
          elide: Text.ElideRight
        }
      }
      MiniChip { label: "PLAY ALL"; onTriggered: detail.playAll() }
      MiniChip { icon: "󰅁"; onTriggered: detail.back() }
    }

    ListView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: detail.model || []
      cacheBuffer: 420
      spacing: MusicTheme.gapTight
      delegate: ResultRow {
        required property var modelData
        width: ListView.view.width
        title: modelData.title || modelData.name || "Untitled"
        subtitle: modelData.artist || modelData.year || ""
        badge: modelData.track ? String(modelData.track).padStart(2, "0") : ""
        cover: root.coverFor(modelData.coverArt)
        favorite: MusicState.isStarred(modelData)
        onTriggered: detail.play(modelData)
        onAdd: detail.add(modelData)
        onNext: detail.next(modelData)
        onFavoriteToggled: detail.favorite(modelData)
      }
    }
  }
}
