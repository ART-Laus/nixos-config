import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root
  property var client: null
  property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/carpheus-mpv-" + Date.now() + ".sock"
  property bool available: false
  property string error: ""
  property var queue: []
  property var urlMap: ({})
  property var pendingPlay: null
  property int playlistPos: -1
  property var currentTrack: null
  property string mediaPath: ""
  property real timePos: 0
  property real duration: 0
  property bool paused: true
  property bool shuffle: false
  property int repeat: 0
  property var pendingCommands: []
  property var pendingBatches: []

  signal stateChanged()

  property Process mpv: Process {
    command: [
      "mpv",
      "--idle=yes",
      "--no-video",
      "--no-config",
      "--no-terminal",
      "--audio-display=no",
      "--force-window=no",
      "--msg-level=all=error",
      "--input-ipc-server=" + root.socketPath
    ]
    running: true
    stdout: StdioCollector {}
    stderr: StdioCollector {}
    onExited: function (code) {
      root.available = false;
      ipc.running = false;
      root.error = "MPV exited with code " + code;
    }
  }

  property Process ipc: Process {
    command: ["carpheus-mpv-ipc", root.socketPath]
    running: mpv.running
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: function (data) { root.handleMessage(data); }
    }
    stderr: StdioCollector {}
    onRunningChanged: {
      if (ipc.running) {
        root.error = "";
        root.flush();
      }
      else {
        root.available = false;
        if (mpv.running) ipc.running = true;
      }
    }
  }

  property Process commandProc: Process {
    stdout: StdioCollector {}
    stderr: StdioCollector {}
    onRunningChanged: {
      if (!commandProc.running) root.startNextBatch();
    }
  }

  property Timer commandTimer: Timer {
    interval: 1
    onTriggered: {
      if (!root.pendingCommands.length) return;
      root.pendingBatches.push(root.pendingCommands);
      root.pendingCommands = [];
      root.startNextBatch();
    }
  }

  function startNextBatch() {
    if (commandProc.running || !root.pendingBatches.length) return;
    var commands = root.pendingBatches.shift();
    commandProc.command = ["carpheus-mpv-ipc", root.socketPath, JSON.stringify(commands)];
    commandProc.running = true;
  }

  function send(command) {
    root.pendingCommands.push(command);
    commandTimer.restart();
  }

  function flush() {
    root.available = true;
  }

  function handleMessage(data) {
    var msg;
    try {
      msg = JSON.parse(data);
    } catch (e) {
      return;
    }
    if (!msg || typeof msg !== "object") return;
    if (msg.event === "property-change") {
      if (msg.name === "time-pos") root.timePos = Number(msg.data) || 0;
      else if (msg.name === "duration") root.duration = Number(msg.data) || 0;
      else if (msg.name === "pause") root.paused = !!msg.data;
      else if (msg.name === "playlist-pos") root.playlistPos = Number(msg.data) || 0;
      else if (msg.name === "path") {
        root.mediaPath = String(msg.data || "");
        root.resolveTrack();
      } else if (msg.name === "shuffle") root.shuffle = !!msg.data;
      else if (msg.name === "loop-file") {
        if (msg.data === "inf" || Number(msg.data) > 0) root.repeat = 2;
      } else if (msg.name === "loop-playlist") {
        if ((msg.data === "inf" || Number(msg.data) > 0) && root.repeat !== 2) root.repeat = 1;
      }
      root.stateChanged();
      return;
    }
    if (msg.event === "file-loaded" || msg.event === "playlist-replace") root.resolveTrack();
  }

  function resolveTrack() {
    var byPath = root.urlMap[root.mediaPath];
    if (byPath) {
      root.currentTrack = byPath;
      return;
    }
    if (root.playlistPos >= 0 && root.playlistPos < root.queue.length) {
      root.currentTrack = root.queue[root.playlistPos];
    }
  }

  function playQueue(tracks, startIndex) {
    if (!tracks || tracks.length === 0) return;
    if (!root.client) return;
    root.pendingPlay = { tracks: tracks, startIndex: Math.max(0, startIndex || 0) };
    var ids = [];
    for (var i = 0; i < tracks.length; i++) ids.push(String(tracks[i].id));
    root.client.streamUrls(ids);
  }

  function loadQueue(ids, map) {
    var play = root.pendingPlay;
    if (!play) return;
    root.pendingPlay = null;
    var tracks = play.tracks;
    root.queue = tracks;
    root.urlMap = map || {};
    if (tracks.length === 1) {
      root.send(["loadfile", map[String(tracks[0].id)], "replace"]);
      root.send(["set_property", "shuffle", root.shuffle]);
      root.send(["set_property", "pause", false]);
      root.applyRepeat();
      root.currentTrack = tracks[0];
      root.client.saveQueue(ids);
      root.stateChanged();
      return;
    }
    root.send(["stop"]);
    root.send(["playlist-clear"]);
    for (var i = 0; i < tracks.length; i++) {
      var t = tracks[i];
      root.send(["loadfile", map[String(t.id)], "append-play"]);
    }
    root.send(["set_property", "shuffle", root.shuffle]);
    root.send(["set_property", "playlist-pos", play.startIndex]);
    root.send(["set_property", "pause", false]);
    root.applyRepeat();
    root.currentTrack = tracks[play.startIndex] || null;
    root.client.saveQueue(ids);
    root.stateChanged();
  }

  function playTrack(track) {
    root.playQueue([track], 0);
  }

  function stop() {
    root.send(["stop"]);
    root.paused = true;
    root.currentTrack = null;
    root.queue = [];
    root.urlMap = ({});
    root.stateChanged();
  }

  function togglePlaying() {
    root.send(["set_property", "pause", !root.paused]);
    root.paused = !root.paused;
    root.stateChanged();
  }

  function next() {
    root.send(["playlist-next", "weak"]);
  }

  function previous() {
    if (root.timePos > 4) root.send(["seek", 0, "absolute", "exact"]);
    else root.send(["playlist-prev", "weak"]);
  }

  function seek(seconds) {
    root.send(["seek", seconds, "relative", "exact"]);
  }

  function setShuffle(enabled) {
    root.shuffle = !!enabled;
    root.send(["set_property", "shuffle", root.shuffle]);
    root.stateChanged();
  }

  function cycleRepeat() {
    root.repeat = (root.repeat + 1) % 3;
    root.applyRepeat();
    root.stateChanged();
  }

  function applyRepeat() {
    root.send(["set_property", "loop-file", root.repeat === 2 ? "inf" : "no"]);
    root.send(["set_property", "loop-playlist", root.repeat === 1 ? "inf" : "no"]);
  }

  property Connections clientConnection: Connections {
    target: root.client
    function onUrlsFinished(ids, map) { root.loadQueue(ids, map); }
  }
}
