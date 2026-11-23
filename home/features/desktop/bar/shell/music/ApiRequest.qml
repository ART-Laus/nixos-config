import QtQuick
import Quickshell.Io

QtObject {
  id: root
  property string kind: ""
  property var args: []
  readonly property bool running: proc.running
  signal finished(string kind, string text, var args)

  function start(requestKind, requestArgs) {
    root.kind = requestKind;
    root.args = requestArgs;
    proc.running = false;
    proc.running = true;
  }

  property Process proc: Process {
    command: ["carpheus-api", root.kind].concat(root.args)
    stdout: StdioCollector {
      id: stdoutCollector
      onStreamFinished: function () { root.finished(root.kind, stdoutCollector.text, root.args); }
    }
    stderr: StdioCollector {}
  }
}
