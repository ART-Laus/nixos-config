import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.appcenter.core
import qs.appcenter.services
import qs.appcenter.overlays

Scope {
    id: root

    property var pendingCallback: null
    property var trackerReference: WindowTracking

    IpcHandler {
        target: "appCenter"

        function toggle(): void {
            root.withCursorScreen(function (screen) {
                AppState.toggle(screen);
            });
        }

        function open(): void {
            root.withCursorScreen(function (screen) {
                AppState.open(screen, "shortcut");
            });
        }

        function close(): void {
            AppState.close();
        }

        function state(): string {
            var names = [];
            var screens = Quickshell.screens || [];
            for (var i = 0; i < screens.length; i++)
                names.push(String(screens[i].name || ""));
            return JSON.stringify({
                revealed: AppState.revealed,
                screenName: AppState.screenName,
                activeTab: AppState.activeTab,
                triggerHovered: AppState.triggerHovered,
                panelHovered: AppState.panelHovered,
                cursorX: AppState.cursorX,
                cursorY: AppState.cursorY,
                appGridColumns: AppState.appGridColumns,
                appGridCellWidth: AppState.appGridCellWidth,
                pinned: AppState.pinned,
                screens: names,
                backendRunning: ProcessService.backendRunning,
                backendReady: ProcessService.backendReady,
                processCount: ProcessService.processes.length,
                trackerConnected: WindowTracking.socketConnected,
                trackerPath: WindowTracking.socketPath,
                trackerError: WindowTracking.instanceError,
                lastEvent: WindowTracking.lastEvent,
                lastClass: WindowTracking.lastClass,
                lastMatchId: WindowTracking.lastMatchId,
                usageCount: Object.keys(UsageStore.data).length,
                usageData: JSON.stringify(UsageStore.data),
                catalogCount: ApplicationsService.entries.length,
                catalogSample: ApplicationsService.entries.slice(0, 12).map(function (entry) { return entry.id; }).join(",")
            });
        }

        function pin(): void {
            AppState.pinned = true;
        }

        function unpin(): void {
            AppState.pinned = false;
        }

        function applications(): void {
            AppState.setTab("applications");
            root.withCursorScreen(function (screen) {
                AppState.open(screen, "shortcut");
            });
        }

        function processes(): void {
            AppState.setTab("processes");
            root.withCursorScreen(function (screen) {
                AppState.open(screen, "shortcut");
            });
        }

        function launch(id: string): void {
            var entry = ApplicationsService.byId[id] || DesktopEntries.byId(id);
            if (entry)
                ApplicationsService.launch(entry);
        }
    }

    Process {
        id: cursorProc
        command: ["hyprctl", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: function () {
                root.finishCursor(text);
            }
        }
    }

    Timer {
        id: cursorFallback
        interval: 300
        onTriggered: root.finishCursor("")
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            EdgeTrigger {
                targetScreen: modelData
            }
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            AppCenterWindow {
                targetScreen: modelData
            }
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
            var sw = Number(screen.width) || 0;
            var sh = Number(screen.height) || 0;
            if (x >= sx && x < sx + sw && y >= sy && y < sy + sh)
                return screen;
        }
        return null;
    }

    Component.onCompleted: WindowTracking.seed()
}
