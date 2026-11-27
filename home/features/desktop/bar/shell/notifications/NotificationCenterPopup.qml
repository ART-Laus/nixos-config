import QtQuick
import QtQuick.Layouts
import qs.config
import qs.notifications

Rectangle {
    id: root

    signal requestClose()

    radius: NotificationTokens.radiusPanel
    color: NotificationTokens.panel
    border.width: 1
    border.color: NotificationTokens.borderStrong
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: NotificationTokens.alpha(NotificationTokens.mint, 0.045) }
            GradientStop { position: 0.25; color: "transparent" }
            GradientStop { position: 1.0; color: NotificationTokens.alpha(NotificationTokens.lavender, 0.035) }
        }
    }

    Rectangle {
        width: 72
        height: 3
        radius: 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 12
        anchors.leftMargin: NotificationTokens.pad
        color: NotificationTokens.alpha(NotificationTokens.mint, 0.7)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: NotificationTokens.pad
        spacing: NotificationTokens.gap

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    spacing: 8

                    Text {
                        text: "Notifications"
                        color: NotificationTokens.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        Layout.preferredHeight: 22
                        Layout.preferredWidth: unreadLabel.implicitWidth + 14
                        radius: 11
                        color: NotificationTokens.alpha(NotificationTokens.mint, 0.14)
                        border.width: 1
                        border.color: NotificationTokens.alpha(NotificationTokens.mint, 0.25)

                        Text {
                            id: unreadLabel
                            anchors.centerIn: parent
                            text: NotificationStore.unreadCount + " unread"
                            color: NotificationTokens.mint
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Text {
                    text: "Verdant / Living Terminal"
                    color: NotificationTokens.text2
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 4
                }
            }

            NotificationAction {
                label: "Close"
                accent: NotificationTokens.text2
                onClicked: root.requestClose()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: NotificationTokens.divider
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "CATEGORY"
                    color: NotificationTokens.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 5
                    font.weight: Font.DemiBold
                    Layout.preferredWidth: 72
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    NotificationSegment {
                        label: "All"
                        accent: NotificationTokens.mint
                        active: NotificationStore.state.view.category === "all"
                        onClicked: NotificationStore.setView("all", NotificationStore.state.view.status)
                    }
                    NotificationSegment {
                        label: "Personal"
                        accent: NotificationTokens.mint
                        active: NotificationStore.state.view.category === "personal"
                        onClicked: NotificationStore.setView("personal", NotificationStore.state.view.status)
                    }
                    NotificationSegment {
                        label: "System"
                        accent: NotificationTokens.lavender
                        active: NotificationStore.state.view.category === "system"
                        onClicked: NotificationStore.setView("system", NotificationStore.state.view.status)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "STATUS"
                    color: NotificationTokens.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 5
                    font.weight: Font.DemiBold
                    Layout.preferredWidth: 72
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 6

                    NotificationSegment {
                        label: "Inbox"
                        accent: NotificationTokens.mint
                        active: NotificationStore.state.view.status === "inbox"
                        onClicked: NotificationStore.setView(NotificationStore.state.view.category, "inbox")
                    }
                    NotificationSegment {
                        label: "Archive"
                        accent: NotificationTokens.lavender
                        active: NotificationStore.state.view.status === "archived"
                        onClicked: NotificationStore.setView(NotificationStore.state.view.category, "archived")
                    }
                    NotificationSegment {
                        label: "Dismissed"
                        accent: NotificationTokens.text2
                        active: NotificationStore.state.view.status === "dismissed"
                        onClicked: NotificationStore.setView(NotificationStore.state.view.category, "dismissed")
                    }
                    NotificationSegment {
                        label: "Everything"
                        accent: NotificationTokens.sage
                        active: NotificationStore.state.view.status === "all"
                        onClicked: NotificationStore.setView(NotificationStore.state.view.category, "all")
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: NotificationTokens.alpha(NotificationTokens.canvas, 0.22)
            border.width: 1
            border.color: NotificationTokens.alpha(NotificationTokens.border, 0.7)

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                contentWidth: width
                contentHeight: Math.max(list.implicitHeight, height - 16)
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: list
                    width: flick.width
                    spacing: 8

                    Repeater {
                        model: NotificationStore.groups

                        NotificationGroup {
                            required property var modelData
                            width: list.width
                            groupData: modelData
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: NotificationStore.groups.length === 0

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 44
                        height: 44
                        radius: 12
                        color: NotificationTokens.alpha(NotificationTokens.mint, 0.1)
                        border.width: 1
                        border.color: NotificationTokens.alpha(NotificationTokens.mint, 0.18)

                        Text {
                            anchors.centerIn: parent
                            text: "󰂛"
                            color: NotificationTokens.mint
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 4
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Nothing here yet"
                        color: NotificationTokens.text2
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "New notifications will appear here."
                        color: NotificationTokens.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: NotificationTokens.divider
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: "History is kept until you delete it."
                color: NotificationTokens.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 4
                elide: Text.ElideRight
            }

            NotificationAction {
                label: "Archive inbox"
                accent: NotificationTokens.lavender
                onClicked: NotificationStore.archiveInbox()
            }

            NotificationAction {
                label: "Clear history"
                danger: true
                onClicked: NotificationStore.clearHistory()
            }
        }
    }

    Behavior on opacity { NumberAnimation { duration: NotificationTokens.motion } }
}
