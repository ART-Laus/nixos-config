pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.music

QtObject {
  id: root
  property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/carpheus/navidrome.env"
  property string connectionStatus: "idle"
  property string connectionText: "Not connected"
  property string backend: "unavailable"
  property string backendText: "—"
  property string title: "Carpheus Music"
  property string artist: ""
  property string album: ""
  property string year: ""
  property string artwork: ""
  property string currentSongId: ""
  property var currentTrack: null
  property bool favorite: false
  property var scanStatus: ({})
  property bool scanning: false
  property string status: "idle"
  property real timePos: 0
  property real duration: 0
  property bool seeking: false
  property bool paused: true
  property bool shuffle: false
  property int repeat: 0
  property string view: "search"
  property string browserArtKey: ""
  property string browserCover: ""
  property string browserAlbum: ""
  property string browserYear: ""
  property var pendingBrowserPlay: null
  property int browserLookupAttempts: 0
  property string query: ""
  property string pendingQuery: ""
  property var searchResults: ({ artist: [], album: [], song: [] })
  property var albumData: null
  property var artistData: null
  property string lastError: ""
  property string lyricsText: ""
  property var lyricsLines: []
  property bool lyricsSynced: false
  property string lyricsKey: ""
  property string lyricPrev: ""
  property string lyricCurrent: "Lyrics unavailable"
  property string lyricNext: ""
  property int lyricIndex: 0
  property int searchDebounce: 300
  property string preferredMode: "auto"
  property string mprisPreference: "firefox,firefox-esr,chromium,google-chrome,brave-browser"

  property NavidromeClient navidrome: NavidromeClient {
    id: navidrome
    onCheckFinished: root.updateBackend()
    onSearchFinished: function(q, data) { root.applySearch(q, data); }
    onRandomFinished: function(data) { root.applyRandom(data); }
    onAlbumFinished: function(id, data) { root.albumData = data; }
    onArtistFinished: function(id, data) { root.artistData = data; }
    onRequestFailed: function(kind, message) {
      root.lastError = message;
      if (kind === "check") {
        root.connectionStatus = "error";
        root.connectionText = message;
      }
      root.updateMetadata();
    }
    onLookupFinished: function(key, data) {
      if (key !== root.browserArtKey) return;
      var result = (data && (data.searchResult3 || data.song)) || {};
      var songs = result.song || (data && data.song) || [];
      var song = songs.length ? songs[0] : null;
      root.currentSongId = song && song.id ? String(song.id) : "";
      root.currentTrack = song || null;
      root.browserLookupAttempts = song ? 0 : root.browserLookupAttempts;
      root.favorite = root.isStarred(song);
      root.browserAlbum = song && song.album ? String(song.album) : "";
      root.browserYear = song && song.year ? String(song.year) : "";
      if (song && song.coverArt) {
        root.browserCover = String(song.coverArt);
        artworkCache.request(root.browserCover, 300);
      }
      root.updateMetadata();
    }
    onSongFinished: function(id, song) {
      if (String(id || "") !== String(root.currentSongId || "")) return;
      if (song) root.currentTrack = song;
      root.favorite = root.isStarred(song);
      if (song && song.year) root.year = String(song.year);
    }
    onFavoriteChanged: function(id, value) {
      if (String(id || "") === String(root.currentSongId || "")) root.favorite = !!value;
    }
    onScanStatusFinished: function(status) { root.applyScanStatus(status); }
    onQuickScanFinished: function(status) {
      root.scanning = true;
      navidrome.scanStatus();
    }
    onUrlsFinished: function(ids, map) { root.handleBrowserUrls(ids, map); }
    onLyricsFinished: function(key, data) { root.applyLyrics(key, data); }
    onArtworkFinished: function(id, size, path) {
      if (size === 300) root.artworkRefreshTimer.restart();
    }
  }

  property ArtworkCache artworkCache: ArtworkCache {
    id: artworkCache
    client: navidrome
  }

  property MprisController mpris: MprisController {
    id: mpris
    client: navidrome
    preference: root.mprisPreference
    onActivePlayerChanged: root.updateBackend()
  }

  property PlaybackController player: PlaybackController {
    id: player
    client: navidrome
    onStateChanged: root.updateMetadata()
  }

  property FileView configView: FileView {
    path: root.configPath
    watchChanges: true
    printErrors: false
    onLoaded: root.parseConfig(configView.text())
    onTextChanged: root.parseConfig(configView.text())
  }

  property Timer searchTimer: Timer {
    interval: root.searchDebounce
    onTriggered: navidrome.search(root.pendingQuery)
  }

  property Timer artworkRefreshTimer: Timer {
    interval: 1
    onTriggered: root.updateMetadata()
  }

  property Timer progressTimer: Timer {
    interval: 1000
    repeat: true
    running: root.status === "playing" && root.duration > 0 && !root.seeking
    onTriggered: {
      if (root.timePos < root.duration) root.timePos = Math.min(root.duration, root.timePos + 1);
      root.updateLyrics();
    }
  }

  property Timer browserLookupRetry: Timer {
    interval: 2000
    repeat: true
    running: root.backend === "browser" && root.title !== "Nothing playing" && !!root.browserArtKey && !root.currentSongId && root.browserLookupAttempts < 6
    onTriggered: {
      root.browserLookupAttempts++;
      navidrome.lookup(root.browserArtKey, root.title + (root.artist ? " " + root.artist : ""));
    }
  }

  function isStarred(track) {
    if (!track) return false;
    return !!(track.starred || track.starredAt || track.starred === "true");
  }

  function applyScanStatus(status) {
    root.scanStatus = status || ({});
    root.scanning = !!(root.scanStatus && (root.scanStatus.scanning === true || root.scanStatus.scanning === "true"));
  }

  function lyricLineText(line) {
    return line && line.text ? String(line.text) : "";
  }

  function updateLyrics() {
    var lines = root.lyricsLines || [];
    if (!lines.length) {
      root.lyricPrev = "";
      root.lyricCurrent = "Lyrics unavailable";
      root.lyricNext = "";
      root.lyricIndex = 0;
      return;
    }
    var index = 0;
    if (root.lyricsSynced) {
      for (var i = 0; i < lines.length; i++) {
        if (Number(lines[i].time || 0) <= root.timePos + 0.2) index = i;
        else break;
      }
    } else {
      index = Math.min(lines.length - 1, Math.floor((root.timePos / Math.max(1, root.duration)) * lines.length));
    }
    index = Math.max(0, Math.min(lines.length - 1, index));
    root.lyricIndex = index;
    root.lyricPrev = index > 0 ? root.lyricLineText(lines[index - 1]) : "";
    root.lyricCurrent = root.lyricLineText(lines[index]);
    root.lyricNext = index + 1 < lines.length ? root.lyricLineText(lines[index + 1]) : "";
  }

  function applyLyrics(key, data) {
    if (key !== root.lyricsKey) return;
    var value = String((data && (data.value || data.lyrics)) || "");
    var raw = value.split(/\r?\n/);
    var lines = [];
    var synced = false;
    var stamp = /^\[(\d{1,2}):(\d{2}(?:\.\d+)?)\](.*)$/;
    for (var i = 0; i < raw.length; i++) {
      var line = raw[i].trim();
      if (!line) continue;
      var match = line.match(stamp);
      if (match) {
        synced = true;
        var text = String(match[3] || "").trim();
        if (text) lines.push({ time: Number(match[1]) * 60 + Number(match[2]), text: text });
      } else if (line.charAt(0) !== "[") {
        lines.push({ time: 0, text: line });
      }
    }
    if (synced) lines.sort(function (a, b) { return a.time - b.time; });
    root.lyricsText = value;
    root.lyricsLines = lines;
    root.lyricsSynced = synced;
    root.updateLyrics();
  }

  function syncLyrics() {
    var key = String(root.title || "") + "|" + String(root.artist || "");
    if (!root.title || root.title === "Nothing playing" || root.title === "Carpheus Music") {
      root.lyricsKey = "";
      root.lyricsText = "";
      root.lyricsLines = [];
      root.lyricsSynced = false;
      root.updateLyrics();
      return;
    }
    if (root.lyricsKey === key) return;
    root.lyricsKey = key;
    root.lyricsText = "";
    root.lyricsLines = [];
    root.lyricsSynced = false;
    root.updateLyrics();
    navidrome.lyrics(key, root.title, root.artist);
  }

  function parseConfig(text) {
    var cfg = {};
    var lines = String(text || "").split("\n");
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (!line || line.charAt(0) === "#" || line.indexOf("=") < 0) continue;
      var pos = line.indexOf("=");
      cfg[line.slice(0, pos).trim()] = line.slice(pos + 1).trim();
    }
    var url = cfg.CARPPHEUS_NAVIDROME_URL || "";
    navidrome.host = String(url).replace(/^https?:\/\//, "").split("/")[0];
    root.preferredMode = cfg.CARPPHEUS_PLAYBACK_MODE || "auto";
    root.mprisPreference = cfg.CARPPHEUS_MPRIS_PREFERENCE || root.mprisPreference;
    root.searchDebounce = Number(cfg.CARPPHEUS_SEARCH_DEBOUNCE_MS || 300);
    root.lastError = "";
    navidrome.check();
    navidrome.scanStatus();
  }

  function applySearch(query, data) {
    if (!data) return;
    data = data.searchResult3 || data;
    var key = String(query || "").trim().toLowerCase();
    if (key) {
      var cache = Object.assign({}, navidrome.searchCache);
      cache[key] = { at: Date.now(), data: data };
      navidrome.searchCache = cache;
    }
    function matches(value) {
      return !key || String(value || "").toLowerCase().indexOf(key) >= 0;
    }
    root.searchResults = {
      album: (data.album || []).filter(function(item) { return matches(item.name); }),
      artist: (data.artist || []).filter(function(item) { return matches(item.name); }),
      song: (data.song || []).filter(function(item) { return matches(item.title); })
    };
  }

  function applyRandom(data) {
    var songs = (data && data.song) || [];
    var current = root.backend === "standalone" && player.currentTrack ? String(player.currentTrack.id) : "";
    var filtered = songs.filter(function(s) { return String(s.id) !== current; });
    root.playQueue(filtered.length ? filtered : songs, 0);
  }

  function updateBackend() {
    var browserReady = mpris.mode === "browser" && mpris.player;
    var standaloneActive = player.currentTrack || player.queue.length > 0;
    if (root.preferredMode === "browser" && browserReady) root.backend = "browser";
    else if (root.preferredMode === "standalone") root.backend = "standalone";
    else if (browserReady && !standaloneActive && (mpris.player.isPlaying || mpris.player.trackTitle)) root.backend = "browser";
    else root.backend = player.available ? "standalone" : "unavailable";

    root.backendText = root.backend === "browser" ? (mpris.player ? mpris.player.identity : "Browser")
      : root.backend === "standalone" ? "MPV"
      : "Unavailable";
    root.updateMetadata();
  }

  function updateMetadata() {
    if (root.backend === "browser" && mpris.player) {
      var p = mpris.player;
      var metadata = p.metadata || {};
      var created = String(metadata["xesam:contentCreated"] || "");
      var yearMatch = created.match(/\d{4}/);
      var rawTitle = String(p.trackTitle || "Nothing playing");
      var rawKey = rawTitle.trim().toLowerCase();
      var pending = root.pendingBrowserPlay;
      var override = pending ? pending.track : null;
      var expectedKey = override && override.title ? String(override.title).trim().toLowerCase() : "";
      var previousKey = pending ? String(pending.previousKey || "") : "";
      if (override && expectedKey && (rawKey === expectedKey || rawKey.indexOf(expectedKey) === 0)) {
        root.pendingBrowserPlay = null;
        pending = null;
        override = null;
      } else if (override && pending.opened && rawKey !== "stream" && rawKey !== "nothing playing" && rawKey !== previousKey && rawKey.indexOf(expectedKey) < 0) {
        root.pendingBrowserPlay = null;
        pending = null;
        override = null;
      }
      root.title = override ? String(override.title || rawTitle) : rawTitle;
      root.artist = override ? String(override.artist || "") : String(p.trackArtist || "");
      root.album = override ? String(override.album || root.browserAlbum || "") : (root.browserAlbum || String(p.trackAlbum || ""));
      root.year = override ? String(override.year || root.browserYear || "") : (root.browserYear || (yearMatch ? yearMatch[0] : ""));
      var browserArt = String(p.trackArtUrl || "");
      if (!browserArt && root.browserCover) browserArt = artworkCache.path(root.browserCover, 300);
      root.artwork = browserArt;
      root.paused = p.playbackState !== MprisPlaybackState.Playing;
      root.timePos = Number(p.position) || 0;
      root.duration = Number(p.length) || 0;
      root.shuffle = !!p.shuffle;
      root.repeat = p.loopState === MprisLoopState.Track ? 2 : p.loopState === MprisLoopState.Playlist ? 1 : 0;
      root.status = p.playbackState === MprisPlaybackState.Playing ? "playing"
        : p.playbackState === MprisPlaybackState.Paused ? "paused" : "idle";
      if (root.title === "Nothing playing") {
        root.currentSongId = "";
        root.currentTrack = null;
        root.favorite = false;
        root.browserArtKey = "";
        root.browserAlbum = "";
        root.browserYear = "";
      } else {
        var artKey = (root.title + "|" + root.artist).toLowerCase();
        if (root.browserArtKey !== artKey) {
          root.browserArtKey = artKey;
          root.browserCover = override && override.coverArt ? String(override.coverArt) : "";
          root.browserAlbum = override ? String(override.album || "") : "";
          root.browserYear = override ? String(override.year || "") : "";
          if (override) {
            root.browserLookupAttempts = 0;
            root.currentSongId = String(override.id || "");
            root.currentTrack = override;
            root.favorite = root.isStarred(override);
            if (root.browserCover) artworkCache.request(root.browserCover, 300);
          } else {
            root.browserLookupAttempts = 0;
            root.currentSongId = "";
            root.currentTrack = null;
            root.favorite = false;
          }
          navidrome.lookup(artKey, root.title + (root.artist ? " " + root.artist : ""));
        }
      }
      root.syncLyrics();
      return;
    }

    var track = player.currentTrack;
    root.title = track ? String(track.title || "Untitled") : "Carpheus Music";
    root.artist = track ? String(track.artist || "") : "";
    root.album = track ? String(track.album || "") : "";
    root.year = track && track.year ? String(track.year) : "";
    root.currentSongId = track && track.id ? String(track.id) : "";
    root.currentTrack = track || null;
    root.favorite = root.isStarred(track);
    root.artwork = track && track.coverArt ? artworkCache.path(track.coverArt, 300) : "";
    if (track && track.coverArt && !root.artwork) artworkCache.request(track.coverArt, 300);
    root.paused = player.paused;
    root.timePos = player.timePos;
    root.duration = player.duration;
    root.shuffle = player.shuffle;
    root.repeat = player.repeat;
    root.status = track ? (player.paused ? "paused" : "playing")
      : root.connectionStatus === "error" ? "error"
      : root.connectionStatus === "connecting" ? "connecting"
      : "idle";
    root.syncLyrics();
  }

  function search(text) {
    root.query = text;
    root.pendingQuery = text;
    if (!String(text).trim()) {
      root.searchResults = { artist: [], album: [], song: [] };
      searchTimer.stop();
      return;
    }
    searchTimer.restart();
  }

  function openAlbum(id) {
    root.view = "album";
    root.albumData = null;
    navidrome.album(id);
  }

  function openArtist(id) {
    root.view = "artist";
    root.artistData = null;
    navidrome.artist(id);
  }

  function back() {
    root.view = "search";
    root.albumData = null;
    root.artistData = null;
  }

  function shouldUseBrowser() {
    return root.backend === "browser" || root.preferredMode === "browser";
  }

  function handleBrowserUrls(ids, map) {
    var pending = root.pendingBrowserPlay;
    if (!pending) return;
    var id = String(pending.track && pending.track.id ? pending.track.id : "");
    var url = map[id];
    if (!url) return;
    pending.opened = true;
    if (mpris.player && mpris.caps.canControl) mpris.player.pause();
    Qt.openUrlExternally(url);
    if (mpris.player && mpris.caps.canControl) mpris.player.raise();
  }

  function playInBrowser(track) {
    if (!track || !track.id) return;
    player.stop();
    root.pendingBrowserPlay = {
      track: track,
      opened: false,
      previousKey: String(root.title || "").trim().toLowerCase()
    };
    root.backend = "browser";
    root.browserAlbum = String(track.album || "");
    root.browserYear = String(track.year || "");
    root.browserCover = String(track.coverArt || "");
    root.currentSongId = String(track.id);
    root.currentTrack = track;
    root.favorite = root.isStarred(track);
    navidrome.streamUrls([String(track.id)]);
    root.updateMetadata();
  }

  function playTrack(track) {
    if (!track) return;
    if (root.shouldUseBrowser()) root.playInBrowser(track);
    else {
      root.backend = "standalone";
      root.currentTrack = track;
      player.playTrack(track);
      root.updateBackend();
    }
  }

  function playQueue(tracks, startIndex) {
    if (!tracks || tracks.length === 0) return;
    var index = Math.max(0, startIndex || 0);
    if (root.shouldUseBrowser()) root.playInBrowser(tracks[index]);
    else {
      root.backend = "standalone";
      player.playQueue(tracks, index);
      root.updateBackend();
    }
  }

  function playAlbum() {
    if (root.albumData && root.albumData.song) root.playQueue(root.albumData.song, 0);
  }

  function random() {
    navidrome.random(12);
  }

  function togglePlay() {
    if (root.backend === "browser" && mpris.caps.canControl) mpris.togglePlaying();
    else player.togglePlaying();
    root.updateMetadata();
  }

  function next() {
    if (root.backend === "browser" && mpris.caps.canGoNext) mpris.next();
    else player.next();
  }

  function previous() {
    if (root.backend === "browser" && mpris.caps.canGoPrevious) mpris.previous();
    else player.previous();
  }

  function setShuffle(enabled) {
    if (root.backend === "browser" && mpris.caps.shuffleSupported) mpris.setShuffle(enabled);
    else player.setShuffle(enabled);
    root.updateMetadata();
  }

  function cycleRepeat() {
    if (root.backend === "browser" && mpris.caps.loopSupported) {
      var nextState = root.repeat === 0 ? MprisLoopState.Playlist : root.repeat === 1 ? MprisLoopState.Track : MprisLoopState.None;
      mpris.setLoop(nextState);
      root.repeat = nextState === MprisLoopState.Track ? 2 : nextState === MprisLoopState.Playlist ? 1 : 0;
    } else {
      player.cycleRepeat();
    }
    root.updateMetadata();
  }

  function seek(seconds) {
    if (root.backend === "browser" && mpris.caps.canSeek && mpris.player) mpris.player.seek(seconds);
    else player.seek(seconds);
  }

  function toggleFavorite() {
    var id = String(root.currentSongId || "");
    if (!id) return;
    var value = !root.favorite;
    root.favorite = value;
    if (value) navidrome.star(id);
    else navidrome.unstar(id);
  }

  function quickScan() {
    if (root.scanning) return;
    root.scanning = true;
    navidrome.quickScan();
  }
}
