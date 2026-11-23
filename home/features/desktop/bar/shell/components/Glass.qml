import QtQuick
import qs.config

Rectangle {
    id: root

    property int pad: 0

    color: Qt.rgba(Theme.pillBase.r, Theme.pillBase.g, Theme.pillBase.b, Settings.popupFillOpacity)
    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, Settings.popupBorderOpacity)
    border.width: 1
    radius: Settings.popupRadius

    layer.enabled: false
}
