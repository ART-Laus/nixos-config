import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.config
import qs.notifications
import "NotificationModel.js" as Model
import "NotificationText.js" as RichText

Rectangle {
    id: root

    required property var row
    property bool compact: false
    readonly property color categoryAccent: NotificationTokens.categoryAccent(root.row.category)
    readonly property color urgencyAccent: NotificationTokens.urgencyAccent(root.row.urgency, root.row.category)
    readonly property bool critical: root.row.urgency === "critical"
    readonly property color markerAccent: critical ? NotificationTokens.danger : categoryAccent
    readonly property color surfaceTint: root.row.status === "unread"
        ? NotificationTokens.alpha(markerAccent, 0.08)
        : NotificationTokens.statusSurface(root.row.status)

    implicitWidth: 100
    implicitHeight: content.implicitHeight + 20
    radius: NotificationTokens.radiusCard
    color: cardArea.containsMouse ? NotificationTokens.cardHover : NotificationTokens.card
    border.width: 1
    border.color: root.row.status === "unread"
        ? NotificationTokens.alpha(markerAccent, 0.38)
        : (cardArea.containsMouse ? NotificationTokens.borderStrong : NotificationTokens.border)

    Behavior on color { ColorAnimation { duration: NotificationTokens.motionFast } }
    Behavior on border.color { ColorAnimation { duration: NotificationTokens.motionFast } }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.surfaceTint
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 1
        width: 3
        radius: 2
        color: NotificationTokens.alpha(root.markerAccent, root.row.status === "read" ? 0.45 : 0.9)
    }

    MouseArea {
        id: cardArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            Layout.alignment: Qt.AlignTop
            radius: 10
            color: NotificationTokens.alpha(root.markerAccent, 0.14)
            border.width: 1
            border.color: NotificationTokens.alpha(root.markerAccent, 0.22)

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                implicitSize: 18
                asynchronous: true
                source: root.row.appIcon && /^(\/|file:|data:)/.test(root.row.appIcon) ? root.row.appIcon : ""
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: !appIcon.visible
                color: root.markerAccent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                font.bold: true
                text: String(root.row.appName || "?").slice(0, 1).toUpperCase()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        color: NotificationTokens.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        font.weight: Font.DemiBold
                        text: String(root.row.appName || "Notification")
                        elide: Text.ElideRight
                        Layout.maximumWidth: 150
                    }

                    Rectangle {
                        width: 4
                        height: 4
                        radius: 2
                        color: NotificationTokens.alpha(NotificationTokens.text2, 0.5)
                        visible: senderLabel.text.length > 0
                    }

                    Text {
                        id: senderLabel
                        Layout.fillWidth: true
                        color: NotificationTokens.text2
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        text: root.row.sender && root.row.sender !== root.row.appName ? String(root.row.sender)
                            : (root.row.chat && root.row.chat !== root.row.summary ? String(root.row.chat) : "")
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    visible: root.row.status === "unread"
                    Layout.preferredWidth: unreadText.implicitWidth + 10
                    Layout.preferredHeight: 18
                    radius: 9
                    color: NotificationTokens.alpha(root.markerAccent, 0.14)
                    border.width: 1
                    border.color: NotificationTokens.alpha(root.markerAccent, 0.28)

                    Text {
                        id: unreadText
                        anchors.centerIn: parent
                        color: root.markerAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 5
                        font.weight: Font.DemiBold
                        text: "NEW"
                    }
                }

                Text {
                    color: NotificationTokens.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 4
                    text: Model.formatTime(root.row.timestamp)
                }
            }

            Text {
                visible: !root.compact && root.row.summary.length > 0 && root.row.summary !== root.row.body
                Layout.fillWidth: true
                color: NotificationTokens.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                wrapMode: Text.Wrap
                text: String(root.row.summary)
            }

            Text {
                id: bodyText
                Layout.fillWidth: true
                color: NotificationTokens.text2
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                lineHeight: 1.25
                textFormat: Text.RichText
                wrapMode: Text.Wrap
                text: root.compact
                    ? RichText.compactText(root.row, { sender: root.markerAccent, link: NotificationTokens.sage })
                    : RichText.formatBody(root.row.body, NotificationTokens.sage)
                onLinkActivated: function (url) { Qt.openUrlExternally(url); }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    cursorShape: bodyText.hoveredLink.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 2
                spacing: 6

                NotificationAction {
                    label: root.row.status === "unread" ? "Read" : "Unread"
                    accent: root.markerAccent
                    active: root.row.status !== "unread"
                    onClicked: NotificationStore.setStatus(root.row.key, root.row.status === "unread" ? "read" : "unread")
                }

                NotificationAction {
                    label: "Archive"
                    accent: NotificationTokens.lavender
                    visible: root.row.status !== "archived"
                    onClicked: NotificationStore.setStatus(root.row.key, "archived")
                }

                NotificationAction {
                    label: "Dismiss"
                    accent: NotificationTokens.text2
                    visible: root.row.status !== "dismissed"
                    onClicked: {
                        NotificationStore.setStatus(root.row.key, "dismissed");
                        NotificationStore.dismissLive(root.row.key);
                    }
                }

                NotificationAction {
                    label: "Delete"
                    danger: true
                    subtle: true
                    onClicked: NotificationStore.remove(root.row.key)
                }

                Repeater {
                    model: root.row.actionLabels || []

                    NotificationAction {
                        required property var modelData
                        label: String(modelData.label)
                        accent: root.markerAccent
                        subtle: false
                        onClicked: NotificationStore.invokeAction(root.row.key, modelData.index)
                    }
                }
            }
        }
    }
}
