import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.clipboard.core
import qs.clipboard.components
import "../core/Format.js" as Format

PanelWindow {
    id: win

    property var targetScreen: null
    property var modelData: null
    readonly property string screenName: targetScreen ? String(targetScreen.name || "") : ""
    property bool active: ClipboardState.open && ClipboardState.screenName === screenName && screenName.length > 0
    property real progress: 0
    property var visibleEntries: []

    readonly property int panelWidth: Math.min(ClipboardTheme.maxWidth,
        Math.floor((targetScreen ? targetScreen.width : 1280) * ClipboardTheme.widthRatio))
    readonly property int panelHeight: Math.min(ClipboardTheme.maxHeight,
        Math.floor((targetScreen ? targetScreen.height : 800) * ClipboardTheme.heightRatio))

    HyprlandFocusGrab {
        id: focusGrab
        active: win.active
        windows: [win]
        onCleared: function () {
            if (win.active)
                ClipboardState.close();
        }
    }

    WlrLayershell.keyboardFocus: win.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    screen: targetScreen
    implicitWidth: win.panelWidth
    implicitHeight: win.panelHeight
    visible: win.active || win.progress > 0.01
    color: "transparent"
    focusable: true
    aboveWindows: true
    exclusiveZone: 0
    surfaceFormat.opaque: false
    anchors.left: true
    anchors.top: true
    margins.left: targetScreen ? Math.max(8, Math.floor((targetScreen.width - win.panelWidth) / 2)) : 8
    margins.top: targetScreen ? Math.max(16, Math.floor((targetScreen.height - win.panelHeight) / 2)) : 16

    mask: Region { item: content; radius: ClipboardTheme.radius }
    BackgroundEffect.blurRegion: Region { item: content; radius: ClipboardTheme.radius }

    onActiveChanged: function () {
        if (win.active) {
            win.setProgress(1);
            ClipboardService.refresh();
            view.currentIndex = 0;
            focusTimer.restart();
        } else {
            ClipboardState.detailId = 0;
            ClipboardState.confirmAction = "";
            win.setProgress(0);
        }
    }

    function setProgress(value) {
        revealAnimation.to = value;
        revealAnimation.duration = value === 1 ? ClipboardTheme.normal : ClipboardTheme.fast;
        revealAnimation.restart();
    }

    NumberAnimation {
        id: revealAnimation
        target: win
        property: "progress"
        easing.type: Easing.OutCubic
    }

    Timer {
        id: focusTimer
        interval: 60
        onTriggered: search.forceFocus()
    }

    Timer {
        id: copiedTimer
        interval: 700
        onTriggered: ClipboardState.copiedId = 0
    }

    Timer {
        id: toastTimer
        interval: 1800
        onTriggered: ClipboardState.toast = ""
    }

    function refreshVisible() {
        var query = String(ClipboardState.query || "").trim().toLowerCase();
        var tokens = query.split(/\s+/).filter(function (token) { return token.length > 0; });
        var category = ClipboardState.category;
        var result = [];
        var entries = ClipboardService.entries || [];
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (category === "pinned" && !entry.pinned)
                continue;
            if (category === "text" && ["text", "code", "json", "email", "color", "url"].indexOf(entry.kind) < 0)
                continue;
            if (category === "images" && entry.kind !== "image")
                continue;
            if (category === "links" && entry.kind !== "url")
                continue;
            if (tokens.length > 0) {
                var haystack = [entry.preview, entry.filename, entry.domain, entry.kind, entry.app].join(" ").toLowerCase();
                var matches = true;
                for (var t = 0; t < tokens.length; t++) {
                    if (haystack.indexOf(tokens[t]) < 0) {
                        matches = false;
                        break;
                    }
                }
                if (!matches)
                    continue;
            }
            result.push(entry);
        }
        win.visibleEntries = result;
        view.currentIndex = result.length > 0 ? Math.min(Math.max(view.currentIndex, 0), result.length - 1) : -1;
    }

    function currentEntry() {
        if (view.currentIndex < 0 || view.currentIndex >= win.visibleEntries.length)
            return null;
        return win.visibleEntries[view.currentIndex];
    }

    function move(delta) {
        if (win.visibleEntries.length === 0)
            return;
        var next = view.currentIndex + delta;
        if (next < 0)
            next = 0;
        if (next >= win.visibleEntries.length)
            next = win.visibleEntries.length - 1;
        view.currentIndex = next;
        view.positionViewAtIndex(next, ListView.ContainsBoundary);
    }

    function activate(id) {
        if (!id)
            return;
        ClipboardState.selectedId = id;
        ClipboardState.copiedId = id;
        copiedTimer.restart();
        ClipboardService.restore(id);
        ClipboardState.close();
    }

    function deleteCurrent() {
        var entry = win.currentEntry();
        if (!entry)
            return;
        ClipboardState.toast = "Removed from history";
        toastTimer.restart();
        ClipboardService.remove(entry.id);
    }

    function togglePinCurrent() {
        var entry = win.currentEntry();
        if (!entry)
            return;
        ClipboardService.pin(entry.id, !entry.pinned);
        ClipboardState.toast = entry.pinned ? "Unpinned" : "Pinned";
        toastTimer.restart();
    }

    function openDetails(id) {
        if (!id)
            return;
        ClipboardService.get(id);
    }

    function clearSearch() {
        search.text = "";
        ClipboardState.clearQuery();
        search.forceFocus();
    }

    function handleKey(event) {
        if (ClipboardState.confirmAction.length > 0) {
            if (event.key === Qt.Key_Escape) {
                ClipboardState.confirmAction = "";
                event.accepted = true;
            }
            return;
        }
        if (event.key === Qt.Key_Escape) {
            if (ClipboardState.detailId > 0) {
                ClipboardState.detailId = 0;
            } else if (ClipboardState.query.length > 0) {
                win.clearSearch();
            } else {
                ClipboardState.close();
            }
            event.accepted = true;
            return;
        }
        var control = (event.modifiers & Qt.ControlModifier) !== 0;
        var shift = (event.modifiers & Qt.ShiftModifier) !== 0;
        if (control) {
            if (event.key === Qt.Key_F) {
                search.forceFocus();
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_L) {
                win.clearSearch();
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_P) {
                win.togglePinCurrent();
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_Delete) {
                if (shift)
                    ClipboardState.confirmAction = "clearUnpinned";
                else
                    win.deleteCurrent();
                event.accepted = true;
                return;
            }
        }
        if (ClipboardState.detailId > 0)
            return;
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
            win.move(event.key === Qt.Key_Up ? -1 : 1);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            var entry = win.currentEntry();
            if (entry)
                win.activate(entry.id);
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Delete) {
            win.deleteCurrent();
            event.accepted = true;
        }
    }

    Rectangle {
        id: content
        anchors.fill: parent
        radius: ClipboardTheme.radius
        color: ClipboardTheme.surface
        border.color: ClipboardTheme.border
        border.width: 1
        opacity: win.progress
        enabled: win.active && win.progress > 0.3
        scale: 0.985 + 0.015 * win.progress

        transform: Translate { y: (1 - win.progress) * 18 }

        Keys.onPressed: function (event) { win.handleKey(event); }

        Column {
            anchors.fill: parent
            clip: true

            // --- Header -------------------------------------------------
            Item {
                width: parent.width
                height: 104

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.top: parent.top
                    anchors.topMargin: 13
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Clipboard"
                        color: ClipboardTheme.text
                        font.pixelSize: Theme.fontSize + 3
                        font.bold: true
                        font.family: Theme.fontFamily
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: countText.implicitWidth + 18
                        height: 22
                        radius: 11
                        color: Qt.rgba(ClipboardTheme.emerald.r, ClipboardTheme.emerald.g, ClipboardTheme.emerald.b, 0.16)
                        Text {
                            id: countText
                            anchors.centerIn: parent
                            text: String(ClipboardService.counts.all || 0) + " entries"
                            color: ClipboardTheme.emerald
                            font.pixelSize: Theme.fontSize - 4
                            font.family: Theme.fontFamily
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.top: parent.top
                    anchors.topMargin: 13
                    spacing: 12

                    Text {
                        property bool hovered: privacyMouse.containsMouse
                        anchors.verticalCenter: parent.verticalCenter
                        text: ClipboardService.pausedFor > 0 ? "◌ Private" : "○ Collecting"
                        color: hovered || ClipboardService.pausedFor > 0 ? ClipboardTheme.secondary : ClipboardTheme.muted
                        font.pixelSize: Theme.fontSize - 3
                        font.family: Theme.fontFamily

                        MouseArea {
                            id: privacyMouse
                            anchors.fill: parent
                            anchors.margins: -5
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ClipboardService.privacy(ClipboardService.pausedFor > 0 ? 0 : 300);
                                ClipboardState.toast = ClipboardService.pausedFor > 0 ? "Capture resumed" : "Capture paused for 5 min";
                                toastTimer.restart();
                            }
                        }
                    }

                    Text {
                        property bool hovered: clearMouse.containsMouse
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Clear"
                        color: hovered ? ClipboardTheme.accent : ClipboardTheme.muted
                        font.pixelSize: Theme.fontSize - 3
                        font.family: Theme.fontFamily

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            anchors.margins: -5
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ClipboardState.confirmAction = "clearUnpinned"
                        }
                    }

                    Text {
                        property bool hovered: deleteAllMouse.containsMouse
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Delete all"
                        color: hovered ? ClipboardTheme.secondary : ClipboardTheme.muted
                        font.pixelSize: Theme.fontSize - 3
                        font.family: Theme.fontFamily

                        MouseArea {
                            id: deleteAllMouse
                            anchors.fill: parent
                            anchors.margins: -5
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ClipboardState.confirmAction = "clearAll"
                        }
                    }
                }

                SearchField {
                    id: search
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                    placeholder: "Search history, links, code…"
                    onKeyEvent: function (event) { win.handleKey(event); }
                    onTextChanged: ClipboardState.query = text
                    onCleared: win.refreshVisible()
                }
            }

            // --- Categories ---------------------------------------------
            Item {
                width: parent.width
                height: 46

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    CategoryTab {
                        label: "All"; glyph: "◇"; count: ClipboardService.counts.all || 0
                        active: ClipboardState.category === "all"
                        activeColor: ClipboardTheme.accent
                        onClicked: ClipboardState.setCategory("all")
                    }
                    CategoryTab {
                        label: "Pinned"; glyph: "★"; count: ClipboardService.counts.pinned || 0
                        active: ClipboardState.category === "pinned"
                        activeColor: ClipboardTheme.secondary
                        onClicked: ClipboardState.setCategory("pinned")
                    }
                    CategoryTab {
                        label: "Text"; glyph: "▤"; count: ClipboardService.counts.text || 0
                        active: ClipboardState.category === "text"
                        onClicked: ClipboardState.setCategory("text")
                    }
                    CategoryTab {
                        label: "Images"; glyph: "▣"; count: ClipboardService.counts.images || 0
                        active: ClipboardState.category === "images"
                        activeColor: ClipboardTheme.secondary
                        onClicked: ClipboardState.setCategory("images")
                    }
                    CategoryTab {
                        label: "Links"; glyph: "↗"; count: ClipboardService.counts.links || 0
                        active: ClipboardState.category === "links"
                        onClicked: ClipboardState.setCategory("links")
                    }
                }
            }

            // --- History ------------------------------------------------
            Item {
                width: parent.width
                height: parent.height - 104 - 46 - 30

                ListView {
                    id: view
                    anchors.fill: parent
                    model: win.visibleEntries
                    clip: true
                    spacing: 5
                    currentIndex: 0
                    section.property: "group"
                    section.criteria: ViewSection.FullString
                    section.delegate: SectionHeader { }
                    delegate: ClipboardCard {
                        entry: modelData
                        query: ClipboardState.query
                        selected: view.currentIndex === index
                        copied: ClipboardState.copiedId === modelData.id
                        onActivate: function (id) { win.activate(id); }
                        onPin: function (id, pinned) { ClipboardService.pin(id, pinned); }
                        onRemove: function (id) { ClipboardService.remove(id); }
                        onDetails: function (id) { win.openDetails(id); }
                    }
                }

                Text {
                    visible: win.visibleEntries.length === 0
                    anchors.centerIn: parent
                    text: ClipboardState.query.length > 0 ? "No matches" : "Nothing here yet"
                    color: ClipboardTheme.muted
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                }
            }

            // --- Footer -------------------------------------------------
            Item {
                width: parent.width
                height: 30

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    text: ClipboardService.pausedFor > 0
                        ? "Privacy pause · " + ClipboardService.pausedFor + "s · existing history kept"
                        : "↑↓ navigate · Enter copy · Ctrl+P pin · Del remove · Ctrl+Shift+Del clear"
                    color: ClipboardTheme.muted
                    font.pixelSize: Theme.fontSize - 5
                    font.family: Theme.fontFamily
                }
            }
        }

        Rectangle {
            id: toast
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 42
            width: toastLabel.implicitWidth + 30
            height: 30
            radius: 15
            color: Qt.rgba(ClipboardTheme.cardHover.r, ClipboardTheme.cardHover.g, ClipboardTheme.cardHover.b, 0.96)
            border.color: ClipboardTheme.border
            opacity: ClipboardState.toast.length > 0 ? 1 : 0
            z: 18

            Behavior on opacity { NumberAnimation { duration: ClipboardTheme.fast } }

            Text {
                id: toastLabel
                anchors.centerIn: parent
                text: ClipboardState.toast
                color: ClipboardTheme.accent
                font.pixelSize: Theme.fontSize - 3
                font.family: Theme.fontFamily
            }
        }

        DetailView {
            visible: ClipboardState.detailId > 0 && !!ClipboardService.detailEntry
            entry: ClipboardService.detailEntry
            onBack: ClipboardState.detailId = 0
            onCopy: function (id) { win.activate(id); }
            onKeyEvent: function (event) { win.handleKey(event); }
        }

        ConfirmDialog {
            visible: ClipboardState.confirmAction.length > 0
            title: ClipboardState.confirmAction === "clearAll" ? "Delete everything?" : "Clear history?"
            message: ClipboardState.confirmAction === "clearAll"
                ? "This removes pinned entries and all stored data. This cannot be undone."
                : "Pinned entries are kept. Only the ordinary history will be removed."
            confirmLabel: ClipboardState.confirmAction === "clearAll" ? "Delete all" : "Clear"
            onConfirmed: function () {
                var all = ClipboardState.confirmAction === "clearAll";
                ClipboardService.clearUnpinned(all);
                ClipboardState.confirmAction = "";
                ClipboardState.toast = all ? "All data deleted" : "History cleared";
                toastTimer.restart();
            }
            onCancelled: function () { ClipboardState.confirmAction = ""; }
        }
    }

    Connections {
        target: ClipboardService
        function onListChanged() { win.refreshVisible(); }
        function onEntryReceived(entry) {
            if (entry)
                ClipboardState.detailId = entry.id;
        }
    }

    Connections {
        target: ClipboardState
        function onQueryChanged() {
            win.refreshVisible();
            view.currentIndex = 0;
        }
        function onCategoryChanged() {
            win.refreshVisible();
            view.currentIndex = 0;
        }
    }
}
