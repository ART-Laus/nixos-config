import QtQuick
import qs.music

QtObject {
  id: root
  property string status: "idle"
  property string statusText: "Not connected"
  property string host: ""
  property var info: ({})
  property var lastError: ({})
  property var searchCache: ({})
  property string pendingSearch: ""
  property string pendingLookup: ""
  property string pendingFavorite: ""
  property string pendingLyrics: ""
  property var requests: [req0, req1, req2, req3, req4, req5]
  property var queue: []

  signal checkFinished(var info)
  signal searchFinished(string query, var data)
  signal albumFinished(string id, var data)
  signal albumsFinished(var data)
  signal artistFinished(string id, var data)
  signal randomFinished(var data)
  signal lookupFinished(string key, var data)
  signal songFinished(string id, var song)
  signal favoriteChanged(string id, bool value)
  signal scanStatusFinished(var status)
  signal quickScanFinished(var status)
  signal urlsFinished(var ids, var map)
  signal lyricsFinished(string key, var data)
  signal artworkFinished(string id, int size, string path)
  signal requestFailed(string kind, string message)

  function request(kind, args) {
    for (var i = 0; i < root.requests.length; i++) {
      if (!root.requests[i].running) {
        root.requests[i].start(kind, args);
        return true;
      }
    }
    root.queue.push({ kind: kind, args: args });
    if (root.queue.length > 64) root.queue.shift();
    return false;
  }

  function pump() {
    while (root.queue.length > 0) {
      var started = false;
      for (var i = 0; i < root.requests.length; i++) {
        if (root.requests[i].running) continue;
        var next = root.queue.shift();
        root.requests[i].start(next.kind, next.args);
        started = true;
        break;
      }
      if (!started) return;
    }
  }

  function check() {
    root.status = "connecting";
    root.statusText = "Connecting…";
    root.request("check", []);
  }

  function search(query) {
    var key = (query || "").trim().toLowerCase();
    if (!key) {
      root.searchFinished(key, { artist: [], album: [], song: [] });
      return;
    }
    var cached = root.searchCache[key];
    if (cached && Date.now() - cached.at < 60000) {
      root.searchFinished(key, cached.data);
      return;
    }
    root.pendingSearch = key;
    root.request("search", [query]);
  }

  function lookup(key, query) {
    if (!String(query || "").trim()) {
      root.lookupFinished(key, { song: [] });
      return;
    }
    root.pendingLookup = key;
    root.request("lookup", [query]);
  }

  function song(id) { root.request("song", [id]); }
  function star(id) {
    root.pendingFavorite = id;
    root.request("star", [id]);
  }
  function unstar(id) {
    root.pendingFavorite = id;
    root.request("unstar", [id]);
  }
  function scanStatus() { root.request("scanstatus", []); }
  function quickScan() { root.request("scanquick", []); }

  function album(id) { root.request("album", [id]); }
  function albums() { root.request("albums", []); }
  function artist(id) { root.request("artist", [id]); }
  function random(count) { root.request("random", [count]); }
  function queue() { root.request("queueget", []); }
  function saveQueue(ids) { root.request("queuesave", ids); }
  function artwork(id, size) { root.request("artwork", [id, size]); }
  function lyrics(key, artist, title) {
    root.pendingLyrics = key;
    root.request("lyrics", [artist || "", title || ""]);
  }

  function streamUrls(ids) {
    if (!ids || ids.length === 0) {
      root.urlsFinished(ids, {});
      return;
    }
    root.request("streamurls", ids);
  }

  function fail(kind, message) {
    root.lastError = { kind: kind, message: message };
    root.requestFailed(kind, message);
  }

  function unwrap(text) {
    var parsed;
    try {
      parsed = JSON.parse(text);
    } catch (e) {
      return null;
    }
    if (!parsed) return null;
    if (parsed.status === "failed" && parsed.error) {
      root.fail("api", parsed.error.message || "Navidrome request failed");
      return null;
    }
    var inner = parsed["subsonic-response"] || parsed;
    if (inner && inner.status === "failed" && inner.error) {
      root.fail("api", inner.error.message || "Navidrome request failed");
      return null;
    }
    return inner;
  }

  function handle(kind, text, args) {
    var data = kind === "check" || kind === "streamurls" || kind === "artwork" ? null : root.unwrap(text);
    if (kind !== "check" && kind !== "streamurls" && kind !== "artwork" && !data) return;

    if (kind === "check") {
      var checkData;
      try {
        checkData = JSON.parse(text);
      } catch (e) {
        checkData = null;
      }
      var response = checkData && checkData.ping ? (checkData.ping["subsonic-response"] || checkData.ping) : null;
      if (response && response.status === "ok") {
        root.status = "ok";
        root.statusText = "Connected";
        root.info = checkData || {};
        root.lastError = ({});
        root.checkFinished(root.info);
      } else {
        var message = response && response.error ? response.error.message : "Navidrome connection failed";
        root.status = "error";
        root.statusText = message;
        root.fail("check", message);
      }
      return;
    }

    if (kind === "search") {
      root.searchFinished(root.pendingSearch, data);
      root.pendingSearch = "";
      return;
    }
    if (kind === "lookup") {
      root.lookupFinished(root.pendingLookup, data);
      root.pendingLookup = "";
      return;
    }
    if (kind === "song") {
      root.songFinished(args && args[0] ? String(args[0]) : "", data && data.song ? data.song : null);
      return;
    }
    if (kind === "star" || kind === "unstar") {
      var favoriteId = String(root.pendingFavorite || (args && args[0] ? args[0] : ""));
      root.favoriteChanged(favoriteId, kind === "star");
      root.pendingFavorite = "";
      return;
    }
    if (kind === "scanstatus") {
      root.scanStatusFinished(data && data.scanStatus ? data.scanStatus : data);
      return;
    }
    if (kind === "scanquick") {
      root.quickScanFinished(data && data.scanStatus ? data.scanStatus : data);
      return;
    }
    if (kind === "album") {
      var album = data && data.album ? data.album : data;
      root.albumFinished(album && album.id ? String(album.id) : "", album);
      return;
    }
    if (kind === "albums") { root.albumsFinished(data && data.albumList2 ? data.albumList2 : data); return; }
    if (kind === "artist") {
      var artist = data && data.artist ? data.artist : data;
      root.artistFinished(artist && artist.id ? String(artist.id) : "", artist);
      return;
    }
    if (kind === "random") { root.randomFinished(data && data.randomSongs ? data.randomSongs : data); return; }
    if (kind === "lyrics") {
      root.lyricsFinished(root.pendingLyrics, data && data.lyrics ? data.lyrics : null);
      root.pendingLyrics = "";
      return;
    }
    if (kind === "artwork") {
      var art = text.trim();
      root.artworkFinished(args && args[0] ? args[0] : "", args && args[1] ? Number(args[1]) : 0, art);
      return;
    }
    if (kind === "streamurls") {
      var map;
      try {
        map = JSON.parse(text);
      } catch (e) {
        map = {};
      }
      root.urlsFinished(Object.keys(map), map);
    }
  }

  property ApiRequest req0: ApiRequest { onFinished: function (kind, text, args) { root.handle(kind, text, args); root.pump(); } }
  property ApiRequest req1: ApiRequest { onFinished: function (kind, text, args) { root.handle(kind, text, args); root.pump(); } }
  property ApiRequest req2: ApiRequest { onFinished: function (kind, text, args) { root.handle(kind, text, args); root.pump(); } }
  property ApiRequest req3: ApiRequest { onFinished: function (kind, text, args) { root.handle(kind, text, args); root.pump(); } }
  property ApiRequest req4: ApiRequest { onFinished: function (kind, text, args) { root.handle(kind, text, args); root.pump(); } }
  property ApiRequest req5: ApiRequest { onFinished: function (kind, text, args) { root.handle(kind, text, args); root.pump(); } }
}
