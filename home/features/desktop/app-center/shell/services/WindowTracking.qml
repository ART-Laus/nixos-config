pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.appcenter.services

QtObject {
    id: root

    property var seen: ({})
    property var lastTouch: ({})
    property string instanceSignature: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || ""
    property string instanceError: ""
    property string lastEvent: ""
    property string lastClass: ""
    property string lastMatchId: ""
    property string socketRoot: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
    property string socketPath: instanceSignature.length > 0 ? socketRoot + "/hypr/" + instanceSignature + "/.socket2.sock" : ""
    readonly property bool socketConnected: internal.socketLoader.item ? internal.socketLoader.item.connected : false

    signal activeWindowChanged(string windowClass)

    property QtObject internal: Item {
        id: internal

        property Process instanceProc: Process {
            id: instanceProc
            command: ["hyprctl", "instances", "-j"]
            stdout: StdioCollector {
                onStreamFinished: function () {
                    var rows = [];
                    try {
                        rows = JSON.parse(text) || [];
                    } catch (e) {
                        return;
                    }
                    if (rows.length > 0)
                        root.instanceSignature = String(rows[0].instance || rows[0].signature || "");
                }
            }
            stderr: StdioCollector {
                onStreamFinished: function () {
                    root.instanceError = text;
                }
            }
        }

        property Process clientsProc: Process {
            id: clientsProc
            command: ["hyprctl", "clients", "-j"]
            stdout: StdioCollector {
                onStreamFinished: function () {
                    root.seedFromJson(text);
                }
            }
        }

        property Loader socketLoader: Loader {
            id: socketLoader
            active: root.socketPath.length > 0
            sourceComponent: Component {
                Socket {
                    path: root.socketPath
                    connected: true
                    parser: SplitParser {
                        onRead: function (line) {
                            root.handleEvent(line);
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: root.seed()

    function seed() {
        if (root.instanceSignature.length === 0)
            internal.instanceProc.running = true;
        internal.clientsProc.running = true;
    }

    function seedFromJson(text) {
        var rows = [];
        try {
            rows = JSON.parse(text) || [];
        } catch (e) {
            return;
        }
        var map = {};
        for (var i = 0; i < rows.length; i++) {
            var address = rows[i].address;
            if (address)
                map[address] = rows[i].class || rows[i].initialClass || "";
        }
        root.seen = map;
    }

    function handleEvent(line) {
        if (!line || line.indexOf(">>") < 0)
            return;
        var parts = line.split(">>");
        var event = parts[0];
        var data = parts.slice(1).join(">>").split(",");
        root.lastEvent = event;
        if (event === "openwindow") {
            var address = data[0] || "";
            var windowClass = data[2] || "";
            if (!address || root.seen[address])
                return;
            root.seen[address] = windowClass;
            root.lastClass = windowClass;
            root.lastMatchId = ApplicationsService.lookupClass(windowClass) ? ApplicationsService.lookupClass(windowClass).id : "";
            if (String(windowClass).toLowerCase().indexOf("quickshell") >= 0)
                return;
            ApplicationsService.touchClass(windowClass);
            root.lastTouch[String(windowClass).toLowerCase()] = Date.now();
        } else if (event === "closewindow") {
            var closed = data[0] || "";
            if (closed)
                delete root.seen[closed];
        } else if (event === "activewindow") {
            var activeClass = data[0] || "";
            root.lastClass = activeClass;
            root.activeWindowChanged(activeClass);
            var key = String(activeClass).toLowerCase();
            if (!key || key.indexOf("quickshell") >= 0)
                return;
            var now = Date.now();
            if (!root.lastTouch[key] || now - root.lastTouch[key] > 600000) {
                root.lastMatchId = ApplicationsService.lookupClass(activeClass) ? ApplicationsService.lookupClass(activeClass).id : "";
                ApplicationsService.touchClass(activeClass);
                root.lastTouch[key] = now;
            }
        }
    }
}
