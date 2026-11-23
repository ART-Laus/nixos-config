import QtQuick

QtObject {
  id: root
  property var client: null
  property var paths: ({})
  property var pending: ({})

  function key(id, size) { return String(id || "") + "@" + size; }

  function path(id, size) {
    if (!id) return "";
    return root.paths[root.key(id, size)] || "";
  }

  function request(id, size) {
    if (!id || !root.client) return;
    var k = root.key(id, size);
    if (root.paths[k] || root.pending[k]) return;
    root.pending[k] = Date.now();
    root.client.artwork(id, size);
  }

  property Timer staleTimer: Timer {
    interval: 25000
    repeat: true
    running: true
    onTriggered: {
      var next = Object.assign({}, root.pending);
      var changed = false;
      for (var k in next) {
        if (Date.now() - Number(next[k]) > 25000) {
          delete next[k];
          changed = true;
        }
      }
      if (changed) root.pending = next;
    }
  }

  property Connections clientConnection: Connections {
    target: root.client
    function onArtworkFinished(id, size, path) {
      if (!id) return;
      var k = root.key(id, size);
      if (path) {
        var next = Object.assign({}, root.paths);
        next[k] = "file://" + path;
        root.paths = next;
      }
      var waiting = Object.assign({}, root.pending);
      delete waiting[k];
      root.pending = waiting;
    }
  }
}
