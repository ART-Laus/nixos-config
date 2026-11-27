import QtQuick
import qs.config

Rectangle {
    id: root

    property bool active: false
    property bool emphasized: false
    property string tooltip: ""
    readonly property bool hovered: area.containsMouse
    property int padding: 10
    property int spacing: 6
    property int iconSize: 18
    signal clicked(var mouse)
    signal middleClicked(var mouse)
    signal rightClicked(var mouse)
    signal wheeled(var delta)

    default property alias content: contentRow.data
    property alias overlay: overlayLayer.data

    implicitWidth: contentRow.implicitWidth + padding * 2
    implicitHeight: Settings.pillHeight
    radius: height / 2
    color: active ? Theme.pillActive
        : area.containsMouse ? Theme.pillHover
        : Theme.pill

    Behavior on color { ColorAnimation { duration: Settings.animationDuration } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.spacing
    }

    Item {
        id: overlayLayer
        anchors.fill: parent
        z: 2
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) root.clicked(mouse);
            else if (mouse.button === Qt.MiddleButton) root.middleClicked(mouse);
            else if (mouse.button === Qt.RightButton) root.rightClicked(mouse);
        }
        onWheel: function (wheel) { root.wheeled(wheel.angleDelta.y); }
    }

    Rectangle {
        id: tooltipBox
        z: 10
        visible: root.tooltip.length > 0 && area.containsMouse
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: tooltipText.implicitWidth + 16
        implicitHeight: tooltipText.implicitHeight + 10
        color: Theme.tooltip
        radius: 8
        opacity: 0.98

        Text {
            id: tooltipText
            anchors.centerIn: parent
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
            text: root.tooltip
        }
    }
}
