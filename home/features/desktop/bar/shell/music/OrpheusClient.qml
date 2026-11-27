import QtQuick
import Quickshell
import Quickshell.Io

// Thin typed facade over the Orpheus daemon IPC. No audio or Navidrome logic
// lives in QML: every library read, write and transport command is dispatched
// to the single coordinator.
QtObject {
  id: root
  property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/orpheus/coordinator.sock"
  property bool connected: false
  property var state: ({})
  property var pendingCalls: []
  property var callbacks: ({})
  property int nextRequestId: 1
  property string lastError: ""

  signal snapshotChanged(var data)
  signal callFinished(string method, var result)
  signal callFailed(string method, string message)

  function handleLine(data, isResponse) {
    var msg;
    try { msg = JSON.parse(String(data || "")); } catch (e) { return; }
    if (!msg || typeof msg !== "object") return;
    if (msg.event === "stateChanged" && msg.data) {
      root.state = msg.data;
      root.lastError = String(msg.data.lastError || "");
      root.snapshotChanged(msg.data);
      return;
    }
    if (!isResponse) return;
    var id = Number(msg.id);
    var entry = root.callbacks[String(id)];
    var callbacks = Object.assign({}, root.callbacks);
    delete callbacks[String(id)];
    root.callbacks = callbacks;
    var method = entry ? String(entry.method || "") : "";
    if (msg.ok) {
      if (method === "getState" && msg.result) {
        root.state = msg.result;
        root.lastError = String(msg.result.lastError || "");
        root.snapshotChanged(msg.result);
      }
      if (entry && typeof entry.success === "function") entry.success(msg.result, method);
      root.callFinished(method, msg.result);
    } else {
      var err = msg.error && msg.error.message ? String(msg.error.message) : "IPC request failed";
      root.lastError = err;
      if (entry && typeof entry.error === "function") entry.error(err, method);
      root.callFailed(method, err);
    }
  }

  function pump() {
    if (caller.running || !root.pendingCalls.length) return;
    var next = root.pendingCalls.shift();
    caller.requestId = Number(next.id);
    caller.requestMethod = String(next.method || "");
    caller.command = ["orpheus-ipc", "call", root.socketPath, caller.requestMethod,
                      JSON.stringify(next.params || {}), String(caller.requestId)];
    caller.running = true;
  }

  function call(method, params, success, error) {
    var id = root.nextRequestId++;
    var callbacks = Object.assign({}, root.callbacks);
    callbacks[String(id)] = { method: String(method), success: success, error: error };
    root.callbacks = callbacks;
    root.pendingCalls.push({ id: id, method: String(method), params: params || {} });
    if (root.pendingCalls.length > 64) {
      var dropped = root.pendingCalls.shift();
      var stale = Object.assign({}, root.callbacks);
      delete stale[String(dropped.id)];
      root.callbacks = stale;
      root.callFailed(String(dropped.method), "IPC queue overflow");
    }
    root.pump();
    return id;
  }

  // Typed methods. Callbacks receive (result, method) / (message, method).
  function getState(success, error) { return call("getState", {}, success, error); }
  function ping(success, error) { return call("ping", {}, success, error); }
  function search(params, success, error) { return call("search", params || {}, success, error); }
  function getArtists(params, success, error) { return call("getArtists", params || {}, success, error); }
  function getAlbumList2(params, success, error) { return call("getAlbumList2", params || {}, success, error); }
  function getGenres(success, error) { return call("getGenres", {}, success, error); }
  function getSongsByGenre(params, success, error) { return call("getSongsByGenre", params || {}, success, error); }
  function getStarred2(params, success, error) { return call("getStarred2", params || {}, success, error); }
  function getAlbum(id, success, error) { return call("getAlbum", { id: String(id) }, success, error); }
  function getArtist(id, success, error) { return call("getArtist", { id: String(id) }, success, error); }
  function getSong(id, success, error) { return call("getSong", { id: String(id) }, success, error); }
  function getRandom(count, success, error) { return call("getRandom", { count: Number(count) || 12 }, success, error); }
  function getScanStatus(success, error) { return call("getScanStatus", {}, success, error); }
  function getLyrics(params, success, error) { return call("getLyrics", params || {}, success, error); }
  function getCoverArt(id, size, success, error) {
    return call("getCoverArt", { id: String(id), size: Number(size) || 300 }, success, error);
  }
  function getPlaylists(success, error) { return call("getPlaylists", {}, success, error); }
  function getPlaylist(id, success, error) { return call("getPlaylist", { id: String(id) }, success, error); }
  function createPlaylist(name, success, error) { return call("createPlaylist", { name: String(name) }, success, error); }
  function updatePlaylist(params, success, error) { return call("updatePlaylist", params || {}, success, error); }
  function deletePlaylist(id, success, error) { return call("deletePlaylist", { id: String(id) }, success, error); }
  function setFavorite(id, value, success, error) {
    return call("setFavorite", { id: String(id), value: !!value }, success, error);
  }
  function setRating(id, value, success, error) {
    return call("setRating", { id: String(id), rating: Number(value) || 0 }, success, error);
  }
  function quickScan(success, error) { return call("quickScan", {}, success, error); }

  function playTrack(id, success, error) { return call("playTrack", { id: String(id) }, success, error); }
  function playQueue(ids, index, success, error) {
    return call("playQueue", { ids: ids || [], index: Number(index) || 0 }, success, error);
  }
  function playAlbum(id, success, error) { return call("playAlbum", { id: String(id) }, success, error); }
  function playPlaylist(id, success, error) { return call("playPlaylist", { id: String(id) }, success, error); }
  function queueAdd(ids, next, success, error) {
    return call("queueAdd", { ids: ids || [], next: !!next }, success, error);
  }
  function playNext(ids, success, error) { return call("playNext", { ids: ids || [] }, success, error); }
  function queueRemove(index, success, error) {
    return call("queueRemove", { index: Number(index) }, success, error);
  }
  function queueMove(from, to, success, error) {
    return call("queueMove", { from: Number(from), to: Number(to) }, success, error);
  }
  function queueClear(success, error) { return call("queueClear", {}, success, error); }
  function queueShuffle(success, error) { return call("queueShuffle", {}, success, error); }
  function togglePlay(success, error) { return call("togglePlay", {}, success, error); }
  function play(success, error) { return call("play", {}, success, error); }
  function pause(success, error) { return call("pause", {}, success, error); }
  function stop(success, error) { return call("stop", {}, success, error); }
  function next(success, error) { return call("next", {}, success, error); }
  function previous(success, error) { return call("previous", {}, success, error); }
  function seek(seconds, success, error) { return call("seek", { seconds: Number(seconds) || 0 }, success, error); }
  function seekAbsolute(seconds, success, error) {
    return call("seekAbsolute", { seconds: Math.max(0, Number(seconds) || 0) }, success, error);
  }
  function setShuffle(value, success, error) { return call("setShuffle", { value: !!value }, success, error); }
  function setRepeat(value, success, error) { return call("setRepeat", { value: Number(value) || 0 }, success, error); }
  function setVolume(value, success, error) {
    return call("setVolume", { value: Math.max(0, Math.min(1, Number(value) || 0)) }, success, error);
  }
  function setMute(value, success, error) { return call("setMute", { value: !!value }, success, error); }
  function toggleFavorite(success, error) { return call("toggleFavorite", {}, success, error); }

  property Process subscriber: Process {
    command: ["orpheus-ipc", "subscribe", root.socketPath]
    running: true
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function (data) { root.handleLine(data, false); }
    }
    stderr: StdioCollector {}
    onRunningChanged: {
      root.connected = running;
      if (running) root.getState();
      else root.retry.restart();
    }
    onExited: function (code) {
      root.connected = false;
      root.lastError = "Orpheus daemon disconnected (code " + code + ")";
      root.retry.restart();
    }
  }

  property Timer retry: Timer {
    interval: 2000
    repeat: true
    running: true
    onTriggered: {
      if (!subscriber.running) subscriber.running = true;
    }
  }

  property Timer callRetry: Timer {
    interval: 1000
    repeat: false
    onTriggered: root.pump()
  }

  property Process caller: Process {
    property int requestId: 0
    property string requestMethod: ""
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function (data) { root.handleLine(data, true); }
    }
    stderr: StdioCollector {}
    onExited: function (code) {
      root.caller.requestMethod = "";
      if (code !== 0) {
        root.lastError = "orpheus-ipc exited with code " + code;
        root.callRetry.restart();
      } else {
        root.pump();
      }
    }
  }
}
