import QtQuick
import qs.components
import qs.config
import qs.services

Glass {
    id: root
    width: 300
    height: 150

    Column {
        anchors.fill: parent
        anchors.margins: Settings.popupPadding
        spacing: 10

        Item {
            width: parent.width
            height: Theme.fontSize + 4

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.primary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                text: "Brightness"
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                text: System.brightness + "%"
            }
        }

        MiniSlider {
            width: parent.width
            from: 0
            to: 100
            value: System.brightness
            onValueChanged: {
                if (Math.abs(value - System.brightness) > 0.5) System.setBrightness(value);
            }
        }

        Row {
            spacing: 6
            width: parent.width

            Repeater {
                model: [10, 25, 50, 75, 100]

                ActionButton {
                    required property var modelData
                    label: modelData + "%"
                    active: System.brightness === modelData
                    onClicked: System.setBrightness(modelData)
                }
            }
        }
    }
}
