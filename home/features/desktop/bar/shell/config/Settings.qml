pragma Singleton
import QtQuick

QtObject {
    readonly property int barHeight: 35
    readonly property int pillHeight: 30
    readonly property int topMargin: 12
    readonly property int sideMargin: 12
    readonly property int sectionSpacing: 12
    readonly property int popupRadius: 24
    readonly property int popupPadding: 14
    readonly property real popupFillOpacity: 0.72
    readonly property real popupBorderOpacity: 0.18
    readonly property int animationDuration: 140
    readonly property int volumeStep: 5
    readonly property int brightnessStep: 5
    readonly property string layoutDevice: "at-translated-set-2-keyboard"
}
