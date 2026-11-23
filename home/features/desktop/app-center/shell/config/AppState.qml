pragma Singleton
import QtQuick
import qs.config

QtObject {
    id: root

    property bool revealed: false
    property bool pinned: false
    property bool triggerHovered: false
    property bool panelHovered: false
    property int cursorX: -1
    property int cursorY: -1
    property int appGridColumns: 0
    property real appGridCellWidth: 0
    property var screen: null
    property string screenName: ""
    property string activeTab: "applications"
    property string query: ""
    property var pendingScreen: null

    readonly property bool hovered: triggerHovered || panelHovered
    readonly property bool interactive: revealed

    signal opened(var screen, string reason)
    signal closed()
    signal tabChanged(string tab)

    property QtObject timers: Item {
        id: timers

        Timer {
            id: openTimer
            interval: AppSettings.revealDelay
            onTriggered: {
                if (root.triggerHovered || root.pinned)
                    root.open(root.pendingScreen, "edge");
            }
        }

        Timer {
            id: hideTimer
            interval: AppSettings.hideDelay
            onTriggered: {
                if (!root.hovered && !root.pinned)
                    root.close();
            }
        }
    }

    function open(targetScreen, reason) {
        if (targetScreen !== null && targetScreen !== undefined) {
            screen = targetScreen;
            screenName = String(targetScreen.name || "");
        }
        var wasRevealed = revealed;
        revealed = true;
        hideTimer.stop();
        if (!wasRevealed)
            opened(screen, reason || "manual");
    }

    function close() {
        if (!revealed)
            return;
        revealed = false;
        screenName = "";
        pinned = false;
        triggerHovered = false;
        panelHovered = false;
        openTimer.stop();
        hideTimer.stop();
        closed();
    }

    function toggle(targetScreen) {
        if (revealed)
            close();
        else
            open(targetScreen, "shortcut");
    }

    function setHover(source, value, targetScreen) {
        if (source === "trigger") {
            triggerHovered = value;
            if (value) {
                pendingScreen = targetScreen;
                hideTimer.stop();
                openTimer.start();
            } else {
                openTimer.stop();
                scheduleHide();
            }
        } else if (source === "panel") {
            panelHovered = value;
            if (value)
                hideTimer.stop();
            else
                scheduleHide();
        }
    }

    function scheduleHide() {
        if (!revealed || pinned || hovered)
            return;
        hideTimer.restart();
    }

    function setTab(tab) {
        if (activeTab === tab)
            return;
        activeTab = tab;
        tabChanged(tab);
    }

    function clearQuery() {
        query = "";
    }
}
