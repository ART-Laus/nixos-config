import QtQuick
import qs.config

Rectangle {
    id: root

    property var script: ({})
    property bool selected: false
    property bool running: false
    signal clicked()
    signal runClicked()
    signal favoriteClicked()
    signal editClicked()

    width: parent ? parent.width : 260
    height: 64
    radius: 10
    color: root.selected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
        : area.containsMouse ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.06)
        : Qt.rgba(0, 0, 0, 0.2)
    border.width: 1
    border.color: root.selected ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.38)
        : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.08)

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Item {
        anchors.fill: parent
        anchors.margins: 8

        Text {
            id: iconText
            anchors.left: parent.left
            anchors.top: parent.top
            width: 24
            color: root.running ? Theme.secondary : Theme.primary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            horizontalAlignment: Text.AlignHCenter
            text: root.script.icon || "󰘲"
        }

        Column {
            anchors.left: iconText.right
            anchors.leftMargin: 8
            anchors.right: actions.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                width: parent.width
                color: root.selected ? Theme.primary : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                font.bold: true
                elide: Text.ElideRight
                text: root.script.name || root.script.filename || root.script.id
            }

            Text {
                width: parent.width
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 5
                elide: Text.ElideRight
                text: root.script.description || root.script.category || root.script.source || ""
            }
        }

        Row {
            id: actions
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            HubButton {
                compact: true
                label: ""
                icon: root.script.favorite ? "󰅷" : "󰅶"
                active: !!root.script.favorite
                onClicked: root.favoriteClicked()
            }

            HubButton {
                compact: true
                label: ""
                icon: "󰇪"
                onClicked: root.editClicked()
            }

            HubButton {
                compact: true
                label: ""
                icon: root.running ? "■" : "▶"
                accent: !root.running
                destructive: root.running
                onClicked: root.runClicked()
            }
        }
    }
}
