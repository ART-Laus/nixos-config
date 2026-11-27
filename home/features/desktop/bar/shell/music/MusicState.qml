pragma Singleton
import QtQuick
import Quickshell
import qs.music

// The only UI state facade. Playback, library, artwork, lyrics, playlists,
// favorites and ratings all come from the Orpheus daemon over IPC.
QtObject {
  id: root

  property OrpheusClient client: OrpheusClient {
    id: client
    onSnapshotChanged: function (data) { root.applyDaemonState(data); }
    onCallFailed: function (method, message) {
      root.lastError = String(message || "");
      root.libraryLoading = false;
    }
  }

  property ArtworkCache artworkCache: ArtworkCache {
    id: artworkCache
    client: root.client
  }

  readonly property var daemonState: client.state || {}
  readonly property bool ipcConnected: client.connected
  property string connectionStatus: "connecting"
  property string connectionText: "Connecting to Orpheus…"
  property string backend: "unavailable"
  property string backendText: "Orpheus offline"

  property string title: "Carpheus Music"
  property string artist: ""
  property string album: ""
  property string year: ""
  property string artwork: ""
  property string currentSongId: ""
  property var currentTrack: null
  property bool favorite: false
  property bool mute: false
  property bool buffering: false
  property real volume: 1
  property string status: "stopped"
  property real timePos: 0
  property real duration: 0
  property bool shuffle: false
  property int repeat: 0
  property string lastError: ""

  property string view: "home"
  property string query: ""
  property var searchResults: ({ artist: [], album: [], song: [] })
  property var albumData: null
  property var artistData: null
  property var playlistData: null
  property string librarySection: "home"
  property var libraryData: ({})
  property var libraryItems: []
  property int libraryOffset: 0
  property bool libraryHasMore: false
  property bool libraryLoading: false
  property var genres: []
  property var playlists: []
  property var favorites: ({})
  property var scanStatus: ({})
  property bool scanning: false

  property string lyricsText: ""
  property var lyricsLines: []
  property bool lyricsSynced: false
  property string lyricsKey: ""
  property string lyricPrev: ""
  property string lyricCurrent: "Lyrics unavailable"
  property string lyricNext: ""
  property int lyricIndex: 0

  property int searchRequest: 0
  property int libraryRequest: 0
  property int lyricsRequest: 0

  onTimePosChanged: root.updateLyrics()

  function asArray(value) {
    if (Array.isArray(value)) return value;
    if (!value) return [];
    return [value];
  }

  function withCovers(value) {
    var items = asArray(value);
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      if (item && !item.coverArt && typeof item === "object") {
        var cover = item.albumId || item.parent || item.id;
        if (cover) item.coverArt = String(cover);
      }
    }
    return items;
  }

  function normalizeGenres(values) {
    var source = asArray(values);
    var result = [];
    for (var i = 0; i < source.length; i++) {
      var item = source[i];
      if (!item) continue;
      if (typeof item === "string") result.push({ name: item, value: item });
      else {
        var name = String(item.name || item.value || "");
        result.push(Object.assign({}, item, { name: name, value: name }));
      }
    }
    return result;
  }

  function isStarred(track) {
    if (!track) return false;
    return !!(track.starred || track.starredAt || track.starred === "true");
  }

  function applyScanStatus(status) {
    root.scanStatus = status || ({});
    root.scanning = !!(root.scanStatus && (
      root.scanStatus.scanning === true || root.scanStatus.scanning === "true"
    ));
  }

  function updateBackend() {
    if (!root.ipcConnected) {
      root.connectionStatus = "connecting";
      root.connectionText = "Connecting to Orpheus…";
      root.backend = "unavailable";
      root.backendText = "Orpheus offline";
      return;
    }
    root.connectionStatus = String(root.daemonState.connectionStatus || "connected");
    root.connectionText = String(root.daemonState.connectionText || "Orpheus connected");
    root.backend = "standalone";
    root.backendText = "Orpheus · mpv";
  }

  function applyDaemonState(data) {
    var state = data || {};
    root.updateBackend();
    var track = state.track || null;
    root.title = track ? String(track.title || "Untitled") : "Carpheus Music";
    root.artist = track ? String(track.artist || "") : "";
    root.album = track ? String(track.album || "") : "";
    root.year = track && track.year ? String(track.year) : "";
    root.currentSongId = track && track.id ? String(track.id) : "";
    root.currentTrack = track;
    root.favorite = !!(state.favorite || (track && root.isStarred(track)));
    root.status = String(state.status || "stopped");
    root.timePos = Number(state.position) || 0;
    root.duration = Number(state.duration) || 0;
    root.shuffle = !!state.shuffle;
    root.repeat = Number(state.repeat) || 0;
    root.volume = Number(state.volume) || 0;
    root.mute = !!state.mute;
    root.buffering = !!state.buffering;
    root.lastError = String(state.lastError || client.lastError || "");
    var cover = track ? (track.coverArt || track.albumId || track.id) : "";
    root.artwork = cover ? artworkCache.path(cover, 300) : "";
    if (cover && !root.artwork) artworkCache.request(cover, 300);
    root.syncLyrics();
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
      index = Math.min(lines.length - 1, Math.floor(
        (root.timePos / Math.max(1, root.duration)) * lines.length
      ));
    }
    index = Math.max(0, Math.min(lines.length - 1, index));
    root.lyricIndex = index;
    root.lyricPrev = index > 0 ? root.lyricLineText(lines[index - 1]) : "";
    root.lyricCurrent = root.lyricLineText(lines[index]);
    root.lyricNext = index + 1 < lines.length ? root.lyricLineText(lines[index + 1]) : "";
  }

  function applyLyrics(key, data) {
    if (key !== root.lyricsKey) return;
    var value = "";
    if (data) {
      if (typeof data === "string") value = data;
      else if (data.lyrics) value = String(data.lyrics);
      else if (data.text) value = String(data.text);
      else if (data.value) value = String(data.value);
      else if (data.structuredLyrics && data.structuredLyrics.length) {
        var first = data.structuredLyrics[0];
        var lines = first && first.line ? first.line : [];
        value = lines.map(function (line) {
          var stamp = line.start ? Number(line.start) / 1000 : 0;
          var minutes = Math.floor(stamp / 60);
          var seconds = (stamp % 60).toFixed(2);
          return "[" + minutes + ":" + (seconds < 10 ? "0" : "") + seconds + "]" + (line.value || "");
        }).join("\n");
      }
    }
    var raw = value.split(/\r?\n/);
    var parsed = [];
    var synced = false;
    var stamp = /^\[(\d{1,2}):(\d{2}(?:\.\d+)?)\](.*)$/;
    for (var i = 0; i < raw.length; i++) {
      var line = raw[i].trim();
      if (!line) continue;
      var match = line.match(stamp);
      if (match) {
        synced = true;
        var text = String(match[3] || "").trim();
        if (text) parsed.push({ time: Number(match[1]) * 60 + Number(match[2]), text: text });
      } else if (line.charAt(0) !== "[") {
        parsed.push({ time: 0, text: line });
      }
    }
    if (synced) parsed.sort(function (a, b) { return a.time - b.time; });
    root.lyricsText = value;
    root.lyricsLines = parsed;
    root.lyricsSynced = synced;
    root.updateLyrics();
  }

  function syncLyrics() {
    if (!root.currentSongId || root.status === "stopped") {
      root.lyricsKey = "";
      root.lyricsText = "";
      root.lyricsLines = [];
      root.lyricsSynced = false;
      root.updateLyrics();
      return;
    }
    var key = root.currentSongId;
    if (root.lyricsKey === key) return;
    root.lyricsKey = key;
    root.lyricsText = "";
    root.lyricsLines = [];
    root.lyricsSynced = false;
    root.updateLyrics();
    var token = ++root.lyricsRequest;
    root.client.getLyrics(
      { id: key, title: root.title, artist: root.artist },
      function (result) {
        if (token !== root.lyricsRequest) return;
        root.applyLyrics(key, result);
      }
    );
  }

  function applySearch(query, data) {
    var source = (data && data.searchResult3) || data || {};
    root.searchResults = {
      artist: withCovers(source.artist),
      album: withCovers(source.album),
      song: withCovers(source.song)
    };
  }

  function search(text) {
    root.query = String(text || "");
    var token = ++root.searchRequest;
    if (!root.query.trim()) {
      root.searchResults = { artist: [], album: [], song: [] };
      return;
    }
    root.client.search({ query: root.query }, function (result) {
      if (token !== root.searchRequest) return;
      root.lastError = "";
      root.applySearch(root.query, result);
    });
  }

  function setSection(section, params) {
    root.librarySection = String(section || "home");
    root.libraryOffset = Number(params && params.offset) || 0;
    root.view = root.librarySection;
    return loadSection(root.librarySection, root.libraryOffset, false);
  }

  function loadSection(section, offset, append) {
    var name = String(section || root.librarySection || "home");
    var at = Math.max(0, Number(offset) || 0);
    var token = ++root.libraryRequest;
    root.libraryLoading = true;
    root.librarySection = name;
    root.libraryOffset = at;

    function done(data, hasMore) {
      if (token !== root.libraryRequest) return;
      root.lastError = "";
      root.libraryLoading = false;
      root.libraryHasMore = !!hasMore;
      if (name === "home") {
        root.libraryData = data || {};
        root.libraryItems = [];
      } else {
        var incoming = withCovers(data);
        root.libraryItems = append ? root.libraryItems.concat(incoming) : incoming;
        root.libraryData = { items: root.libraryItems };
      }
    }

    if (name === "home") {
      var home = { recentAlbums: [], randomSongs: [], genres: [], favorites: [] };
      var pending = 4;
      function finishHome() {
        if (--pending === 0) done(home, false);
      }
      root.client.getAlbumList2({ type: "newest", size: 12, offset: 0 }, function (result) {
        home.recentAlbums = withCovers(result && result.album);
        finishHome();
      }, finishHome);
      root.client.getRandom(8, function (result) {
        home.randomSongs = withCovers((result && result.song) || (result && result.entry));
        finishHome();
      }, finishHome);
      root.client.getGenres(function (result) {
        root.genres = normalizeGenres((result && result.genre) || result);
        home.genres = root.genres;
        finishHome();
      }, finishHome);
      root.client.getStarred2({ songCount: 24 }, function (result) {
        var starred = result || {};
        home.favorites = withCovers(starred.song);
        root.favorites = {
          songs: home.favorites,
          albums: withCovers(starred.album),
          artists: withCovers(starred.artist)
        };
        finishHome();
      }, finishHome);
      return token;
    }
    if (name === "artists") {
      root.client.getArtists({}, function (result) {
        var groups = (result && result.index) || [];
        var artists = [];
        for (var i = 0; i < groups.length; i++) {
          var group = groups[i];
          var children = asArray(group && group.artist);
          for (var j = 0; j < children.length; j++) artists.push(children[j]);
        }
        done(artists, false);
      });
      return token;
    }
    if (name === "albums") {
      var size = 60;
      root.client.getAlbumList2({
        type: "alphabeticalByName", size: size, offset: at
      }, function (result) {
        var albums = withCovers(result && result.album);
        done(albums, albums.length >= size);
      });
      return token;
    }
    if (name === "tracks") {
      var trackSize = 80;
      root.client.search({
        query: "", artistCount: 0, albumCount: 0,
        songCount: trackSize, songOffset: at
      }, function (result) {
        var songs = withCovers(result && result.song);
        done(songs, songs.length >= trackSize);
      });
      return token;
    }
    if (name === "genres") {
      root.client.getGenres(function (result) {
        var values = normalizeGenres((result && result.genre) || result);
        root.genres = values;
        done(values, false);
      });
      return token;
    }
    if (name === "playlists") {
      root.client.getPlaylists(function (result) {
        var values = withCovers((result && result.playlist) || result);
        root.playlists = values;
        done(values, false);
      });
      return token;
    }
    if (name === "favorites") {
      root.client.getStarred2({}, function (result) {
        var starred = result || {};
        root.favorites = {
          songs: withCovers(starred.song),
          albums: withCovers(starred.album),
          artists: withCovers(starred.artist)
        };
        done(root.favorites.songs, false);
      });
      return token;
    }
    done([], false);
    return token;
  }

  function loadMore() {
    if (!root.libraryHasMore || root.libraryLoading) return;
    loadSection(root.librarySection, root.libraryOffset + root.libraryItems.length, true);
  }

  function openAlbum(id) {
    root.view = "album";
    root.albumData = null;
    root.client.getAlbum(String(id), function (result) { root.albumData = result || null; });
  }

  function openArtist(id) {
    root.view = "artist";
    root.artistData = null;
    root.client.getArtist(String(id), function (result) { root.artistData = result || null; });
  }

  function openPlaylist(id) {
    root.view = "playlist";
    root.playlistData = null;
    root.client.getPlaylist(String(id), function (result) { root.playlistData = result || null; });
  }

  function openGenre(name) {
    root.view = "genre";
    root.libraryLoading = true;
    root.client.getSongsByGenre({ genre: String(name), count: 100, offset: 0 }, function (result) {
      var songs = withCovers((result && result.song) || result);
      root.libraryItems = songs;
      root.libraryData = { genre: String(name), items: songs };
      root.libraryLoading = false;
      root.libraryHasMore = false;
    }, function () {
      root.libraryLoading = false;
    });
  }

  function createPlaylist(name) {
    root.client.createPlaylist(String(name), function (result) {
      root.client.getPlaylists(function (playlists) {
        root.playlists = withCovers((playlists && playlists.playlist) || playlists);
      });
    });
  }

  function deletePlaylist(id) {
    root.client.deletePlaylist(String(id), function () {
      root.playlistData = null;
      root.client.getPlaylists(function (playlists) {
        root.playlists = withCovers((playlists && playlists.playlist) || playlists);
      });
    });
  }

  function back() {
    root.view = root.librarySection || "home";
    root.albumData = null;
    root.artistData = null;
    root.playlistData = null;
  }

  function playTrack(track) {
    if (!track || !track.id) return;
    root.client.playTrack(String(track.id));
  }

  function playQueue(tracks, startIndex) {
    var ids = [];
    var items = asArray(tracks);
    for (var i = 0; i < items.length; i++) {
      if (items[i] && items[i].id) ids.push(String(items[i].id));
    }
    if (ids.length) root.client.playQueue(ids, Math.max(0, Number(startIndex) || 0));
  }

  function playAlbum() {
    if (root.albumData && root.albumData.id) root.client.playAlbum(String(root.albumData.id));
    else if (root.albumData && root.albumData.song) root.playQueue(root.albumData.song, 0);
  }

  function playPlaylist() {
    if (root.playlistData && root.playlistData.id) root.client.playPlaylist(String(root.playlistData.id));
    else if (root.playlistData && root.playlistData.song) root.playQueue(root.playlistData.song, 0);
  }

  function queueAdd(tracks, next) {
    var ids = [];
    var items = asArray(tracks);
    for (var i = 0; i < items.length; i++) {
      if (items[i] && items[i].id) ids.push(String(items[i].id));
    }
    if (ids.length) root.client.queueAdd(ids, !!next);
  }

  function queueRemove(index) { root.client.queueRemove(Number(index)); }
  function queueMove(from, to) { root.client.queueMove(Number(from), Number(to)); }
  function queueClear() { root.client.queueClear(); }
  function shuffleQueue() { root.client.queueShuffle(); }

  function random() {
    root.client.getRandom(12, function (result) {
      var songs = (result && result.song) || (result && result.entry) || [];
      if (songs.length) root.playQueue(songs, 0);
    });
  }

  function togglePlay() { root.client.togglePlay(); }
  function next() { root.client.next(); }
  function previous() { root.client.previous(); }
  function setShuffle(enabled) { root.client.setShuffle(!!enabled); }
  function cycleRepeat() { root.client.setRepeat((root.repeat + 1) % 3); }
  function seekBy(seconds) { root.client.seek(Number(seconds) || 0); }
  function seekTo(seconds) { root.client.seekAbsolute(Math.max(0, Number(seconds) || 0)); }
  function setVolume(value) { root.client.setVolume(value); }
  function toggleMute() { root.client.setMute(!root.mute); }
  function toggleFavorite() { root.client.toggleFavorite(); }
  function setFavorite(id, value) { root.client.setFavorite(String(id), !!value); }
  function setRating(id, value) { root.client.setRating(String(id), Number(value) || 0); }

  function quickScan() {
    if (root.scanning) return;
    root.scanning = true;
    root.client.quickScan(function () {
      root.client.getScanStatus(function (status) { root.applyScanStatus(status); });
    }, function () {
      root.applyScanStatus({ scanning: false });
    });
  }
}
