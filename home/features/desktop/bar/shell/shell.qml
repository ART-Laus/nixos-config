import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import qs.appcenter
import qs.components
import qs.config
import qs.music
import qs.notifications
import qs.popups
import qs.scripthub
import qs.widgets

ShellRoot {
    id: root

    PanelWindow {
        id: bar
        implicitHeight: Settings.barHeight
        color: "transparent"
        visible: true
        focusable: false
        aboveWindows: true
        exclusiveZone: Settings.barHeight + Settings.topMargin
        exclusionMode: ExclusionMode.Normal
        surfaceFormat.opaque: false
        anchors.left: true
        anchors.right: true
        anchors.top: true
        margins.top: Settings.topMargin

        mask: Region {
            item: surface
            radius: Settings.popupRadius
        }

        Rectangle {
            id: surface
            anchors.fill: parent
            color: "transparent"
            radius: Settings.popupRadius
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: Settings.sideMargin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Settings.sectionSpacing

            Workspaces {}
            Battery {}
            ScriptHubPill { id: scriptHubPill }
            NotificationPill { id: notificationPill }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: Settings.sectionSpacing

            IslandCenter {}
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: Settings.sideMargin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Settings.sectionSpacing

            Tray {}
            Camera {}
            Brightness { id: brightnessPill }
            Audio { id: audioPill }
            Bluetooth { id: bluetoothPill }
            Language {}
            Network { id: networkPill }
            Clock { id: clockPill }
        }

        Text {
            id: osd
            z: 20
            anchors.centerIn: parent
            color: Theme.primary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            opacity: UIState.osdText.length > 0 ? 1 : 0
            text: UIState.osdText

            Behavior on opacity {
                NumberAnimation { duration: Settings.animationDuration }
            }
        }

        Timer {
            id: osdTimer
            interval: 1600
            repeat: false
            onTriggered: UIState.osdText = ""
        }

        Connections {
            target: UIState
            function onOsdTextChanged() {
                if (UIState.osdText.length > 0) osdTimer.restart();
            }
        }

        PopupWindow {
            id: brightnessPopup
            implicitWidth: 300
            implicitHeight: 150
            color: "transparent"
            grabFocus: true
            surfaceFormat.opaque: false
            visible: UIState.activePopup === "brightness"
            anchor.item: brightnessPill
            anchor.edges: Edges.Top | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            anchor.margins.top: 8
            mask: Region { item: brightnessContent; radius: Settings.popupRadius }
            BackgroundEffect.blurRegion: Region { item: brightnessContent; radius: Settings.popupRadius }
            onClosed: UIState.close("brightness")

            BrightnessPopup {
                id: brightnessContent
                anchors.fill: parent
            }
        }

        PopupWindow {
            id: audioPopup
            implicitWidth: 340
            implicitHeight: 480
            color: "transparent"
            grabFocus: true
            surfaceFormat.opaque: false
            visible: UIState.activePopup === "audio"
            anchor.item: audioPill
            anchor.edges: Edges.Top | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            anchor.margins.top: 8
            mask: Region { item: audioContent; radius: Settings.popupRadius }
            BackgroundEffect.blurRegion: Region { item: audioContent; radius: Settings.popupRadius }
            onClosed: UIState.close("audio")

            AudioPopup {
                id: audioContent
                anchors.fill: parent
            }
        }

        PopupWindow {
            id: bluetoothPopup
            implicitWidth: 330
            implicitHeight: 420
            color: "transparent"
            grabFocus: true
            surfaceFormat.opaque: false
            visible: UIState.activePopup === "bluetooth"
            anchor.item: bluetoothPill
            anchor.edges: Edges.Top | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            anchor.margins.top: 8
            mask: Region { item: bluetoothContent; radius: Settings.popupRadius }
            BackgroundEffect.blurRegion: Region { item: bluetoothContent; radius: Settings.popupRadius }
            onClosed: UIState.close("bluetooth")

            BluetoothPopup {
                id: bluetoothContent
                anchors.fill: parent
            }
        }

        PopupWindow {
            id: networkPopup
            implicitWidth: 350
            implicitHeight: 480
            color: "transparent"
            grabFocus: true
            surfaceFormat.opaque: false
            visible: UIState.activePopup === "network"
            anchor.item: networkPill
            anchor.edges: Edges.Top | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            anchor.margins.top: 8
            mask: Region { item: networkContent; radius: Settings.popupRadius }
            BackgroundEffect.blurRegion: Region { item: networkContent; radius: Settings.popupRadius }
            onClosed: UIState.close("network")

            NetworkPopup {
                id: networkContent
                anchors.fill: parent
            }
        }

        PopupWindow {
            id: calendarPopup
            implicitWidth: 300
            implicitHeight: 300
            color: "transparent"
            grabFocus: true
            surfaceFormat.opaque: false
            visible: UIState.activePopup === "calendar"
            anchor.item: clockPill
            anchor.edges: Edges.Top | Edges.Right
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            anchor.margins.top: 8
            mask: Region { item: calendarContent; radius: Settings.popupRadius }
            BackgroundEffect.blurRegion: Region { item: calendarContent; radius: Settings.popupRadius }
            onClosed: UIState.close("calendar")

            CalendarPopup {
                id: calendarContent
                anchors.fill: parent
            }
        }

        PopupWindow {
            id: scriptHubPopup
            implicitWidth: 620
            implicitHeight: 580
            color: "transparent"
            grabFocus: true
            surfaceFormat.opaque: false
            visible: UIState.activePopup === "scriptHub"
            anchor.item: scriptHubPill
            anchor.edges: Edges.Top | Edges.Left
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            anchor.margins.top: 8
            mask: Region { item: scriptHubContent; radius: Settings.popupRadius }
            BackgroundEffect.blurRegion: Region { item: scriptHubContent; radius: Settings.popupRadius }
            onClosed: UIState.close("scriptHub")

            ScriptHubPopup {
                id: scriptHubContent
                anchors.fill: parent
            }
        }

        PopupWindow {
            id: notificationPopup
            implicitWidth: 520
            implicitHeight: 620
            color: "transparent"
            grabFocus: true
            surfaceFormat.opaque: false
            visible: UIState.activePopup === "notificationCenter"
            anchor.item: notificationPill
            anchor.edges: Edges.Top | Edges.Left
            anchor.gravity: Edges.Bottom | Edges.Left
            anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY
            anchor.margins.top: 8
            mask: Region { item: notificationContent; radius: Settings.popupRadius }
            BackgroundEffect.blurRegion: Region { item: notificationContent; radius: Settings.popupRadius }
            onClosed: UIState.close("notificationCenter")

            NotificationCenterPopup {
                id: notificationContent
                anchors.fill: parent
                onRequestClose: UIState.close("notificationCenter")
            }
        }

        Component.onCompleted: {
            UIState.barWindow = bar;
        }
    }

    AppCenter {}
}
