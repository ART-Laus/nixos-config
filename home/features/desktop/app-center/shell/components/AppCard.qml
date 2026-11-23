import QtQuick
import qs.config
import qs.appcenter.services
import "../core/FuzzySearch.js" as FuzzySearch

Rectangle {
    id: root

    property var entry: null
    property var indices: []
    property bool highlighted: false
    signal activate()
    signal contextRequested(var mouse)

    implicitWidth: 118
    implicitHeight: 104
    radius: AppSettings.cardRadius
    color: mouse.containsMouse || highlighted ? Theme.pillHover : Theme.pill
    border.color: highlighted ? Theme.primary : (mouse.containsMouse ? Theme.primaryDim : "transparent")
    border.width: highlighted ? 2 : 1
    scale: mouse.containsMouse ? AppSettings.hoverScale : 1

    Behavior on color {
        ColorAnimation { duration: AppSettings.transitionFast }
    }
    Behavior on border.color {
        ColorAnimation { duration: AppSettings.transitionFast }
    }
    Behavior on scale {
        NumberAnimation { duration: AppSettings.transitionFast; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: iconBox
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 12
        width: 44
        height: 44
        radius: 12
        color: Theme.pillBase

        Text {
            id: fallbackIcon
            anchors.centerIn: parent
            text: "◇"
            color: Theme.primaryDim
            font.pixelSize: 22
            font.family: Theme.fontFamily
        }

        Image {
            id: icon
            anchors.fill: parent
            anchors.margins: 6
            source: root.entry ? ApplicationsService.iconSource(root.entry) : ""
            sourceSize.width: 48
            sourceSize.height: 48
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: status === Image.Ready
        }
    }

    Text {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        maximumLineCount: 2
        wrapMode: Text.WrapAnywhere
        textFormat: Text.RichText
        color: Theme.text
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.fontFamily
        text: {
            if (!root.entry)
                return "";
            var name = root.entry.name || root.entry.id || "";
            return root.indices && root.indices.length > 0 ? FuzzySearch.marked(name, root.indices) : name;
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: function (event) {
            if (event.button === Qt.RightButton)
                root.contextRequested(event);
            else
                root.activate();
        }
    }
}
