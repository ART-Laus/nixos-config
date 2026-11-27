import QtQuick
import qs.config
import qs.scripthub
import qs.notifications

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
    height: 66
    radius: NotificationTokens.radiusCard

    readonly property color markerColor: root.running ? NotificationTokens.mint
        : root.script.favorite ? NotificationTokens.lavender : NotificationTokens.emerald

    color: root.selected ? NotificationTokens.alpha(NotificationTokens.mint, 0.10)
        : area.containsMouse ? NotificationTokens.alpha(NotificationTokens.text, 0.06)
        : NotificationTokens.card
    border.width: 1
    border.color: root.selected ? NotificationTokens.alpha(NotificationTokens.mint, 0.42)
        : area.containsMouse ? NotificationTokens.borderStrong : NotificationTokens.border

    Behavior on color { ColorAnimation { duration: NotificationTokens.motionFast } }
    Behavior on border.color { ColorAnimation { duration: NotificationTokens.motionFast } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        width: 3
        radius: 2
        color: root.markerColor
        opacity: root.selected || root.running ? 1 : 0.55
    }

    Item {
        anchors.fill: parent
        anchors.margins: 8

        Rectangle {
            id: iconBox
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 28
            height: 28
            radius: NotificationTokens.radiusControl
            color: NotificationTokens.alpha(root.markerColor, 0.11)
            border.width: 1
            border.color: NotificationTokens.alpha(root.markerColor, 0.25)

            Text {
                anchors.centerIn: parent
                color: root.markerColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                text: root.script.icon || "󰘲"
            }
        }

        Column {
            anchors.left: iconBox.right
            anchors.leftMargin: 9
            anchors.right: actions.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                width: parent.width
                color: root.selected ? NotificationTokens.mint : NotificationTokens.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
                elide: Text.ElideRight
                text: root.script.name || root.script.filename || root.script.id
            }

            Text {
                width: parent.width
                color: NotificationTokens.text2
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
