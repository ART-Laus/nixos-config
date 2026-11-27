import QtQuick
import QtQuick.Layouts
import qs.config
import qs.notifications

Rectangle {
    id: root

    required property var groupData
    readonly property color groupAccent: NotificationTokens.categoryAccent(root.groupData.category)

    implicitWidth: 100
    implicitHeight: header.implicitHeight + (root.groupData.open ? list.implicitHeight + 14 : 0) + 10
    radius: NotificationTokens.radiusCard
    color: NotificationTokens.alpha(NotificationTokens.panelAlt, 0.72)
    border.width: 1
    border.color: headerArea.containsMouse ? NotificationTokens.borderStrong : NotificationTokens.border

    Behavior on border.color { ColorAnimation { duration: NotificationTokens.motionFast } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 0

        Rectangle {
            id: header
            Layout.fillWidth: true
            implicitHeight: headerRow.implicitHeight + 12
            radius: 10
            color: headerArea.containsMouse ? NotificationTokens.alpha(root.groupAccent, 0.08) : "transparent"

            Behavior on color { ColorAnimation { duration: NotificationTokens.motionFast } }

            RowLayout {
                id: headerRow
                anchors.fill: parent
                anchors.margins: 6
                spacing: 8

                MouseArea {
                    id: headerArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NotificationStore.toggleExpanded(root.groupData.key)

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 7
                            color: NotificationTokens.alpha(root.groupAccent, 0.14)
                            border.width: 1
                            border.color: NotificationTokens.alpha(root.groupAccent, 0.22)

                            Text {
                                anchors.centerIn: parent
                                color: root.groupAccent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                font.bold: true
                                text: root.groupData.open ? "▾" : "▸"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                color: NotificationTokens.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                text: (root.groupData.appName || "Notification") + (root.groupData.chat ? "  ·  " + root.groupData.chat : "")
                            }

                            Text {
                                color: root.groupData.unread > 0 ? root.groupAccent : NotificationTokens.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 4
                                text: root.groupData.count + " messages" + (root.groupData.unread > 0 ? "  •  " + root.groupData.unread + " unread" : "")
                            }
                        }
                    }
                }

                NotificationAction {
                    label: "Read all"
                    accent: root.groupAccent
                    visible: root.groupData.unread > 0
                    onClicked: {
                        var keys = root.groupData.rows.filter(function (row) { return row.status === "unread"; })
                            .map(function (row) { return row.key; });
                        NotificationStore.setManyStatus(keys, "read");
                    }
                }

                NotificationAction {
                    label: "Archive all"
                    accent: NotificationTokens.lavender
                    onClicked: {
                        var keys = root.groupData.rows.map(function (row) { return row.key; });
                        NotificationStore.setManyStatus(keys, "archived");
                    }
                }
            }
        }

        Column {
            id: list
            Layout.fillWidth: true
            Layout.topMargin: root.groupData.open ? 8 : 0
            spacing: 6
            visible: root.groupData.open
            opacity: root.groupData.open ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: NotificationTokens.motionFast } }

            Repeater {
                model: root.groupData.open ? root.groupData.rows : []

                NotificationCard {
                    required property var modelData
                    width: list.width
                    row: modelData
                }
            }
        }
    }
}
