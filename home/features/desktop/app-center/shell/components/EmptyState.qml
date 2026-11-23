import QtQuick
import qs.config

Item {
    id: root
    property string title: ""
    property string message: ""
    property string icon: "◇"

    implicitWidth: 320
    implicitHeight: column.implicitHeight

    Column {
        id: column
        anchors.centerIn: parent
        width: Math.min(parent.width, 360)
        spacing: 10

        Rectangle {
            width: 56
            height: 56
            radius: AppSettings.cardRadius
            color: Theme.pillBase
            border.color: Theme.pill
            border.width: 1
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: Theme.textDim
                font.pixelSize: 24
                font.family: Theme.fontFamily
            }
        }

        Text {
            width: parent.width
            text: root.title
            color: Theme.text
            font.pixelSize: Theme.fontSize + 2
            font.family: Theme.fontFamily
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Text {
            width: parent.width
            text: root.message
            color: Theme.textDim
            font.pixelSize: Theme.fontSize
            font.family: Theme.fontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
