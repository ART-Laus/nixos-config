import QtQuick
import qs.config

Rectangle {
    id: root

    property string title: "Confirm"
    property string message: ""
    signal confirmed()
    signal cancelled()

    visible: false
    z: 2000
    width: 360
    height: 150
    radius: AppSettings.surfaceRadius
    color: Theme.tooltip
    border.color: Theme.pill
    border.width: 1

    Text {
        id: titleText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        text: root.title
        color: Theme.text
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
        font.family: Theme.fontFamily
    }

    Text {
        id: messageText
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: titleText.bottom
        anchors.topMargin: 8
        anchors.margins: 18
        text: root.message
        color: Theme.textDim
        font.pixelSize: Theme.fontSize - 1
        font.family: Theme.fontFamily
        elide: Text.ElideRight
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16
        spacing: 8

        Rectangle {
            width: 86
            height: 30
            radius: 15
            color: cancelMouse.containsMouse ? Theme.pillHover : "transparent"
            Text {
                anchors.centerIn: parent
                text: "Cancel"
                color: Theme.textDim
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
            }
            MouseArea {
                id: cancelMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    root.visible = false;
                    root.cancelled();
                }
            }
        }

        Rectangle {
            width: 86
            height: 30
            radius: 15
            color: Theme.error
            Text {
                anchors.centerIn: parent
                text: "Confirm"
                color: Theme.inverse
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
                font.family: Theme.fontFamily
            }
            MouseArea {
                id: confirmMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    root.visible = false;
                    root.confirmed();
                }
            }
        }
    }
}
