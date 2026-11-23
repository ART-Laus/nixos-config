import QtQuick
import qs.config

Item {
    id: root
    property string title: ""
    property string subtitle: ""

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    Row {
        id: row
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: root.title
            color: Theme.text
            font.pixelSize: Theme.fontSize
            font.family: Theme.fontFamily
            font.bold: true
        }

        Text {
            visible: root.subtitle !== ""
            text: root.subtitle
            color: Theme.textDim
            font.pixelSize: Theme.fontSize - 1
            font.family: Theme.fontFamily
            anchors.baseline: parent.children[0].baseline
        }
    }
}
