pragma Singleton
import QtQuick
import qs.config

QtObject {
    id: root

    // Surfaces - deep green, layered, readable on blur/wallpapers.
    readonly property color canvas: "#07110D"
    readonly property color panel: Qt.rgba(0.047, 0.106, 0.078, 0.94)
    readonly property color panelAlt: Qt.rgba(0.071, 0.145, 0.106, 0.92)
    readonly property color card: Qt.rgba(0.090, 0.165, 0.122, 0.88)
    readonly property color cardHover: Qt.rgba(0.122, 0.224, 0.165, 0.94)
    readonly property color cardUnread: Qt.rgba(0.102, 0.196, 0.141, 0.10)
    readonly property color border: Qt.rgba(0.176, 0.306, 0.224, 0.55)
    readonly property color borderStrong: Qt.rgba(0.239, 0.420, 0.310, 0.72)
    readonly property color divider: Qt.rgba(0.651, 0.745, 0.690, 0.14)

    // Text - AA-oriented on panel/card surfaces.
    readonly property color text: "#EAF6EF"
    readonly property color text2: "#A7BEB0"
    readonly property color muted: "#86A794"
    readonly property color inverse: "#07110D"

    // Identity accents.
    readonly property color mint: "#66FF99"
    readonly property color emerald: "#36C98B"
    readonly property color sage: "#A5E6B8"
    readonly property color lavender: "#C4A0FF"
    readonly property color lavenderSoft: "#D2BCFF"

    // Status accents.
    readonly property color warning: "#F2C15B"
    readonly property color danger: "#FF7A90"
    readonly property color success: "#36C98B"

    // Geometry.
    readonly property int radiusPanel: 18
    readonly property int radiusCard: 14
    readonly property int radiusControl: 10
    readonly property int radiusPill: 999
    readonly property int gap: 10
    readonly property int pad: 14

    // Motion.
    readonly property int motionFast: Settings.reducedMotion ? 0 : 110
    readonly property int motion: Settings.reducedMotion ? 0 : 150
    readonly property int motionSlow: Settings.reducedMotion ? 0 : 200

    function alpha(colorValue, a) {
        return Qt.rgba(colorValue.r, colorValue.g, colorValue.b, a);
    }

    function categoryAccent(category) {
        return category === "personal" ? mint : lavender;
    }

    function categorySoft(category) {
        return category === "personal" ? sage : lavenderSoft;
    }

    function statusAccent(status, urgency) {
        if (urgency === "critical") return danger;
        if (status === "dismissed") return danger;
        if (status === "archived") return lavender;
        if (status === "unread") return mint;
        return muted;
    }

    function statusSurface(status) {
        if (status === "unread") return cardUnread;
        if (status === "dismissed") return alpha(danger, 0.05);
        if (status === "archived") return alpha(lavender, 0.05);
        return Qt.rgba(1, 1, 1, 0.025);
    }

    function urgencyAccent(urgency, category) {
        if (urgency === "critical") return danger;
        if (urgency === "low") return muted;
        return categoryAccent(category);
    }
}
