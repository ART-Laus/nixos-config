import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.appcenter.services
import qs.appcenter.views
import qs.appcenter.overlays
import qs.appcenter.components

PanelWindow {
    id: root

    property var targetScreen: null
    property var modelData: null
    readonly property string screenName: targetScreen ? String(targetScreen.name || "") : ""
    property bool active: AppState.revealed && AppState.screenName === screenName && screenName.length > 0
    property real progress: 0

    property var detailsProcess: null
    property bool pointerInside: false

    readonly property int panelWidth: Math.min(AppSettings.panelMaxWidth, Math.floor((targetScreen ? targetScreen.width : 1280) * AppSettings.panelWidthRatio))
    readonly property int panelHeight: Math.min(AppSettings.panelMaxHeight, Math.floor((targetScreen ? targetScreen.height : 800) * AppSettings.panelHeightRatio))

    HyprlandFocusGrab {
        id: focusGrab
        active: root.active
        windows: [ root ]

        onCleared: function () {
            if (root.active)
                AppState.close();
        }
    }

    WlrLayershell.keyboardFocus: root.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    screen: targetScreen
    implicitWidth: root.panelWidth
    implicitHeight: root.panelHeight
    visible: root.active || root.progress > 0.01
    color: "transparent"
    focusable: true
    aboveWindows: true
    exclusiveZone: 0
    surfaceFormat.opaque: false
    anchors.left: true
    anchors.bottom: true
    margins.left: targetScreen ? Math.max(0, Math.floor((targetScreen.width - root.panelWidth) / 2)) : 0
    margins.bottom: 32

    mask: Region { item: content; radius: AppSettings.surfaceRadius }
    BackgroundEffect.blurRegion: Region { item: content; radius: AppSettings.surfaceRadius }

    onActiveChanged: function () {
        if (root.active) {
            root.pointerInside = false;
            ProcessService.start();
            appsSearch.text = AppState.query;
            processSearch.text = ProcessService.query;
            root.setProgress(1);
            focusTimer.restart();
        } else {
            appsView.closeOverlays();
            processesView.closeOverlays();
            detailsOverlay.visible = false;
            newProcessDialog.visible = false;
            root.setProgress(0);
            if (!AppState.revealed)
                ProcessService.stop();
        }
    }

    function setProgress(value) {
        if (AppSettings.reducedMotion) {
            root.progress = value;
            return;
        }
        revealAnimation.to = value;
        revealAnimation.duration = value === 1 ? AppSettings.transitionNormal : AppSettings.transitionFast;
        revealAnimation.restart();
    }

    NumberAnimation {
        id: revealAnimation
        target: root
        property: "progress"
        easing.type: Easing.OutCubic
    }

    function isInsideContainer(x, y) {
        if (!targetScreen)
            return false;
        var sx = Number(targetScreen.x) || 0;
        var sy = Number(targetScreen.y) || 0;
        var sw = Number(targetScreen.width) || 0;
        var sh = Number(targetScreen.height) || 0;
        var panelLeft = sx + margins.left;
        var panelTop = sy + sh - margins.bottom - panelHeight;
        var panelRight = panelLeft + panelWidth;
        var panelBottom = panelTop + panelHeight;
        var inPanel = x >= panelLeft && x <= panelRight && y >= panelTop && y <= panelBottom;
        var inCorridor = x >= panelLeft && x <= panelRight && y >= panelBottom && y <= sy + sh;
        var triggerLeft = sx + Math.floor((sw - 200) / 2);
        var triggerTop = sy + sh - 8;
        var inTrigger = x >= triggerLeft && x <= triggerLeft + 200 && y >= triggerTop && y <= sy + sh;
        return inPanel || inCorridor || inTrigger;
    }

    Timer {
        id: pointerPoll
        interval: 200
        running: root.active
        repeat: true
        onTriggered: function () {
            if (!cursorProc.running)
                cursorProc.running = true;
        }
    }

    Process {
        id: cursorProc
        command: ["hyprctl", "-j", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: function () {
                var pos = null;
                try {
                    pos = JSON.parse(text);
                } catch (e) {
                    return;
                }
                var x = Number(pos.x);
                var y = Number(pos.y);
                if (!isFinite(x) || !isFinite(y))
                    return;
                AppState.cursorX = x;
                AppState.cursorY = y;
                var inside = root.isInsideContainer(x, y);
                if (inside !== root.pointerInside) {
                    root.pointerInside = inside;
                    AppState.setHover("panel", inside, targetScreen);
                }
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 70
        onTriggered: {
            if (AppState.activeTab === "applications")
                appsSearch.forceFocus();
            else
                processSearch.forceFocus();
        }
    }

    function showDetails(row) {
        if (!row)
            return;
        root.detailsProcess = row;
        detailsOverlay.visible = true;
    }

    function navigate(key) {
        if (AppState.activeTab === "applications") {
            if (key === Qt.Key_Up)
                appsView.move(-1);
            else if (key === Qt.Key_Down)
                appsView.move(1);
            else if (key === Qt.Key_PageUp)
                appsView.movePage(-1);
            else if (key === Qt.Key_PageDown)
                appsView.movePage(1);
        } else {
            if (key === Qt.Key_Up)
                processesView.move(-1);
            else if (key === Qt.Key_Down)
                processesView.move(1);
            else if (key === Qt.Key_PageUp)
                processesView.move(-7);
            else if (key === Qt.Key_PageDown)
                processesView.move(7);
        }
    }

    function activateCurrent() {
        if (AppState.activeTab === "applications")
            appsView.activateCurrent();
        else if (processesView.selected)
            root.showDetails(processesView.selected);
    }

    function clearOrClose() {
        if (AppState.activeTab === "applications" && appsSearch.text.length > 0) {
            appsSearch.text = "";
            AppState.query = "";
            appsSearch.forceFocus();
        } else if (AppState.activeTab === "processes" && processSearch.text.length > 0) {
            processSearch.text = "";
            ProcessService.query = "";
            processSearch.forceFocus();
        } else {
            AppState.close();
        }
    }

    Connections {
        target: AppState
        function onTabChanged() {
            appsView.closeOverlays();
            processesView.closeOverlays();
            focusTimer.restart();
        }
        function onQueryChanged() {
            if (appsSearch.text !== AppState.query)
                appsSearch.text = AppState.query;
        }
    }

    Connections {
        target: WindowTracking
        function onActiveWindowChanged(windowClass) {
            var key = String(windowClass || "").toLowerCase();
            if (root.active && key.length > 0 && key.indexOf("quickshell") < 0)
                AppState.close();
        }
    }

    Connections {
        target: ProcessService
        function onQueryChanged() {
            if (processSearch.text !== ProcessService.query)
                processSearch.text = ProcessService.query;
        }
        function onResultReceived(result) {
            if (result && result.ok === false && result.message === "critical_process_requires_confirmation")
                root.showDetails(processesView.selected);
        }
    }

    Rectangle {
        id: content
        anchors.fill: parent
        radius: AppSettings.surfaceRadius
        color: Theme.panel
        border.color: Theme.border
        border.width: 1
        opacity: root.progress
        enabled: root.active && root.progress > 0.35

        transform: Translate {
            y: (1 - root.progress) * (content.height + 28)
        }

        Item {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 60

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    visible: content.width > 700
                    text: "Application Center"
                    color: Theme.text
                    font.pixelSize: Theme.fontSize + 2
                    font.family: Theme.fontFamily
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    visible: content.width > 700
                    width: 8
                    height: 1
                }

                TabButton {
                    label: "Applications"
                    count: content.width > 700 ? ApplicationsService.entries.length : -1
                    active: AppState.activeTab === "applications"
                    onClicked: {
                        AppState.setTab("applications");
                        focusTimer.restart();
                    }
                }
                TabButton {
                    label: "Processes"
                    count: content.width > 700 ? ProcessService.visibleProcesses.length : -1
                    active: AppState.activeTab === "processes"
                    onClicked: {
                        AppState.setTab("processes");
                        focusTimer.restart();
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                SearchField {
                    id: appsSearch
                    visible: AppState.activeTab === "applications"
                    width: Math.min(280, Math.max(120, content.width - 272))
                    placeholder: "Search..."
                    onTextChanged: {
                        if (visible && AppState.query !== text)
                            AppState.query = text;
                    }
                    onAccepted: root.activateCurrent()
                    onEscapePressed: root.clearOrClose()
                    onNavigationRequested: function (key) {
                        root.navigate(key);
                    }
                }

                SearchField {
                    id: processSearch
                    visible: AppState.activeTab === "processes"
                    width: Math.min(280, Math.max(120, content.width - 272))
                    placeholder: "Search..."
                    onTextChanged: {
                        if (visible && ProcessService.query !== text)
                            ProcessService.query = text;
                    }
                    onAccepted: root.activateCurrent()
                    onEscapePressed: root.clearOrClose()
                    onNavigationRequested: function (key) {
                        root.navigate(key);
                    }
                }

                Rectangle {
                    visible: AppState.activeTab === "processes" && content.width > 700
                    width: 30
                    height: 30
                    radius: 15
                    color: refreshMouse.containsMouse ? Theme.pillHover : Theme.pill
                    Text {
                        anchors.centerIn: parent
                        text: "↻"
                        color: Theme.textDim
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }
                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ProcessService.snapshotOnce()
                    }
                }

                Rectangle {
                    visible: AppState.activeTab === "processes" && content.width > 700
                    width: 30
                    height: 30
                    radius: 15
                    color: newMouse.containsMouse ? Theme.pillActive : Theme.pill
                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: Theme.primary
                        font.pixelSize: Theme.fontSize + 2
                        font.family: Theme.fontFamily
                    }
                    MouseArea {
                        id: newMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            newProcessDialog.x = Math.floor((content.width - newProcessDialog.width) / 2);
                            newProcessDialog.y = Math.floor((content.height - newProcessDialog.height) / 2);
                            newProcessDialog.visible = true;
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            height: 1
            color: Theme.pill
        }

        ApplicationsView {
            id: appsView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 10
            visible: AppState.activeTab === "applications"
        }

        ProcessesView {
            id: processesView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: 10
            visible: AppState.activeTab === "processes"
            onDetailsRequested: function (row) {
                root.showDetails(row);
            }
            onNewProcessRequested: function () {
                newProcessDialog.visible = true;
            }
        }

        ProcessDetails {
            id: detailsOverlay
            parent: content
            processData: root.detailsProcess
            x: Math.floor((content.width - width) / 2)
            y: Math.floor((content.height - height) / 2)
        }

        NewProcessDialog {
            id: newProcessDialog
            parent: content
        }

        Keys.enabled: root.active
        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                root.clearOrClose();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_PageUp || event.key === Qt.Key_PageDown) {
                root.navigate(event.key);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.activateCurrent();
                event.accepted = true;
            }
        }
    }
}
