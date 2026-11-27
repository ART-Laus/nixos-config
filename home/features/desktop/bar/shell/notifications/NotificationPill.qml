import QtQuick
import qs.components
import qs.config
import qs.notifications

Pill {
    id: root

    active: UIState.activePopup === "notificationCenter"
    tooltip: NotificationStore.unreadCount > 0
        ? "Notification Center  ·  " + NotificationStore.unreadCount + " unread"
        : "Notification Center"

    Row {
        spacing: 6

        Text {
            color: root.active ? NotificationTokens.mint : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            text: "󰍵"
        }

        Text {
            color: root.active ? NotificationTokens.text : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.weight: root.active ? Font.DemiBold : Font.Normal
            text: "Inbox"
        }
    }

    overlay: Rectangle {
        id: badge
        anchors.right: parent.right
        anchors.rightMargin: 3
        anchors.top: parent.top
        anchors.topMargin: 3
        width: Math.max(18, badgeText.implicitWidth + 10)
        height: 18
        radius: 9
        color: NotificationTokens.mint
        border.width: 1
        border.color: NotificationTokens.alpha(NotificationTokens.canvas, 0.35)
        visible: NotificationStore.unreadCount > 0

        Text {
            id: badgeText
            anchors.centerIn: parent
            color: NotificationTokens.inverse
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 6
            font.bold: true
            text: NotificationStore.unreadCount > 99 ? "99+" : String(NotificationStore.unreadCount)
        }
    }

    onClicked: UIState.open("notificationCenter")
}
