import QtQuick
import qs.config

Rectangle {
    id: root

    property real value: 0
    property real from: 0
    property real to: 100
    property color fillColor: Theme.primary

    implicitWidth: 140
    implicitHeight: 4
    radius: height / 2
    color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.12)

    Rectangle {
        width: (root.value - root.from) / (root.to - root.from) * parent.width
        height: parent.height
        color: root.fillColor
        radius: parent.radius
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        drag.target: undefined
        propagateComposedEvents: false

        function apply(xPosition) {
            var ratio = Math.max(0, Math.min(1, xPosition / parent.width));
            root.value = root.from + ratio * (root.to - root.from);
        }

        onPressed: function (mouse) { apply(mouse.x); mouse.accepted = true; }
        onMouseXChanged: function (mouse) { if (pressed) apply(mouse.x); }
    }
}
