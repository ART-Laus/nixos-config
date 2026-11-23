import QtQuick
import qs.config

Item {
    id: root
    property string label: ""
    property string value: ""
    property real ratio: 0
    property color colorValue: Theme.primary

    readonly property real clampedRatio: Math.max(0, Math.min(1, ratio))

    implicitWidth: 160
    implicitHeight: column.implicitHeight

    Column {
        id: column
        width: parent.width
        spacing: 4

        Row {
            width: parent.width

            Text {
                text: root.label
                color: Theme.textDim
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
                width: parent.width - valueText.implicitWidth
                elide: Text.ElideRight
            }

            Text {
                id: valueText
                text: root.value
                color: Theme.text
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
            }
        }

        Rectangle {
            width: parent.width
            height: 4
            radius: 2
            color: Theme.pillBase

            Rectangle {
                height: parent.height
                radius: parent.radius
                width: parent.width * root.clampedRatio
                color: root.colorValue

                Behavior on width {
                    NumberAnimation { duration: AppSettings.transitionNormal }
                }
            }
        }
    }
}
