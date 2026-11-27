pragma Singleton
import QtQuick

QtObject {
    readonly property bool reducedMotion: false

    readonly property int surfaceRadius: 24
    readonly property int cardRadius: 14
    readonly property int cardPadding: 12
    readonly property int rowHeight: 34
    readonly property real hoverScale: 1.03
    // На случай внешних потребителей; сама панель использует Theme.panel.
    readonly property real panelOpacity: 0.94

    readonly property int transitionFast: reducedMotion ? 0 : 120
    readonly property int transitionNormal: reducedMotion ? 0 : 220
    readonly property int transitionSlow: reducedMotion ? 0 : 340

    readonly property int edgeTriggerWidth: 200
    readonly property int edgeTriggerHeight: 8
    readonly property int revealDelay: 150
    readonly property int hideDelay: 500

    readonly property real panelWidthRatio: 0.22
    readonly property real panelHeightRatio: 0.42
    readonly property int panelMaxWidth: 460
    readonly property int panelMaxHeight: 440

    readonly property int processIntervalMs: 1500
    readonly property int recentLimit: 3
}
