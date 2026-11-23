import QtQuick
import qs.config

Rectangle {
    id: root
    property string label: ""
    property bool active: false
    property int count: -1
    signal clicked()

    implicitHeight: 30
    implicitWidth: row.implicitWidth + 20
    radius: height / 2
    color: active ? Theme.pillActive : (mouse.containsMouse ? Theme.pillHover : "transparent")

    Behavior on color {
        ColorAnimation { duration: AppSettings.transitionFast }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.label
            color: root.active ? Theme.text : Theme.textDim
            font.pixelSize: Theme.fontSize
            font.family: Theme.fontFamily
            font.letterSpacing: 0.5
            Behavior on color {
                ColorAnimation { duration: AppSettings.transitionFast }
            }
        }

        Text {
            visible: root.count >= 0
            text: root.count >= 0 ? root.count : ""
            color: Theme.textDim
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.fontFamily
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
