pragma Singleton
import QtQuick
import qs.config

// Verdant / Living Terminal tokens — no separate visual language.
QtObject {
    readonly property color canvas: Theme.inverse                    // #07110D
    readonly property color surface: Theme.panel                     // #0C1B14 @ 0.94
    readonly property color card: Qt.rgba(Theme.section.r, Theme.section.g, Theme.section.b, 0.92)
    readonly property color cardHover: Qt.rgba(0.098, 0.200, 0.145, 0.96)
    readonly property color border: Theme.border
    readonly property color accent: Theme.primary                    // #66FF99
    readonly property color emerald: Theme.primaryDim                // #36C98B
    readonly property color secondary: Theme.secondary               // #C4A0FF
    readonly property color text: Theme.text
    readonly property color textDim: Theme.info                      // #A5E6B8
    readonly property color muted: Theme.muted

    readonly property int maxWidth: 760
    readonly property int maxHeight: 700
    readonly property real widthRatio: 0.60
    readonly property real heightRatio: 0.78
    readonly property int radius: 20
    readonly property int cardRadius: 12
    readonly property int cardHeight: 84
    readonly property int spacing: 8

    readonly property int fast: 110
    readonly property int normal: 200
    readonly property string monoFont: Theme.fontFamily
}
