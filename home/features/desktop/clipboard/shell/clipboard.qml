import QtQuick
import Quickshell
import Quickshell.Io
import qs.clipboard
import qs.clipboard.core
import qs.clipboard.overlays

Scope {
    id: root

    property var pendingCallback: null

    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            if (ClipboardState.open)
                ClipboardState.close();
            else
                root.withCursorScreen(function (screen) { ClipboardState.openOn(String(screen ? screen.name || "" : "")); });
        }

        function open(): void {
            root.withCursorScreen(function (screen) { ClipboardState.openOn(String(screen ? screen.name || "" : "")); });
        }

        function close(): void {
            ClipboardState.close();
        }

        function refresh(): void {
            ClipboardService.refresh();
        }

        function search(text: string): void {
            ClipboardState.query = text;
        }

        function setCategory(category: string): void {
            ClipboardState.setCategory(category);
        }

        function state(): string {
            return JSON.stringify({
                revealed: ClipboardState.open,
                screenName: ClipboardState.screenName,
                query: ClipboardState.query,
                category: ClipboardState.category,
                entries: ClipboardService.entries.length,
                counts: ClipboardService.counts,
                backendOk: ClipboardService.backendOk,
                pausedFor: ClipboardService.pausedFor
            });
        }
    }

    Process {
        id: cursorProc
        command: ["hyprctl", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: function () { root.finishCursor(text); }
        }
    }

    Timer {
        id: cursorFallback
        interval: 300
        onTriggered: function () { root.finishCursor(""); }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            ClipboardWindow { targetScreen: modelData }
        }
    }

    function withCursorScreen(callback) {
        root.pendingCallback = callback;
        cursorFallback.restart();
        cursorProc.running = false;
        cursorProc.running = true;
    }

    function finishCursor(text) {
        if (cursorFallback.running)
            cursorFallback.stop();
        var values = String(text || "").split(",");
        var x = Number(values[0]);
        var y = Number(values[1]);
        var screen = null;
        if (isFinite(x) && isFinite(y))
            screen = root.screenAt(x, y);
        if (!screen && Quickshell.screens.length > 0)
            screen = Quickshell.screens[0];
        var callback = root.pendingCallback;
        root.pendingCallback = null;
        if (callback)
            callback(screen);
    }

    function screenAt(x, y) {
        var screens = Quickshell.screens || [];
        for (var i = 0; i < screens.length; i++) {
            var screen = screens[i];
            var sx = Number(screen.x) || 0;
            var sy = Number(screen.y) || 0;
            if (x >= sx && x < sx + (Number(screen.width) || 0) && y >= sy && y < sy + (Number(screen.height) || 0))
                return screen;
        }
        return null;
    }
}
