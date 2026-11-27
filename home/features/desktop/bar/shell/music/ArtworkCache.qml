import QtQuick

// Small per-surface cache. Every download is a daemon IPC call to getCoverArt;
// the daemon owns the real cache on disk and never fetches all images at once.
QtObject {
  id: root
  property var client: null
  property var paths: ({})
  property var pending: ({})

  function key(id, size) { return String(id || "") + "@" + Number(size || 0); }

  function path(id, size) {
    if (!id) return "";
    return root.paths[root.key(id, size)] || "";
  }

  function request(id, size) {
    if (!id || !root.client) return;
    var k = root.key(id, size);
    if (root.paths[k] || root.pending[k]) return;
    var waiting = Object.assign({}, root.pending);
    waiting[k] = Date.now();
    root.pending = waiting;
    root.client.getCoverArt(String(id), Number(size) || 300, function (result) {
      var localPath = result && result.path ? String(result.path) : "";
      if (localPath) {
        var next = Object.assign({}, root.paths);
        next[k] = "file://" + localPath;
        root.paths = next;
      }
      var done = Object.assign({}, root.pending);
      delete done[k];
      root.pending = done;
    }, function () {
      var failed = Object.assign({}, root.pending);
      delete failed[k];
      root.pending = failed;
    });
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
}
