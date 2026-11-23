import QtQuick
import qs.components
import qs.config
import Quickshell.Io
import qs.services

Glass {
    id: root
    width: 330
    height: Math.min(420, content.implicitHeight + Settings.popupPadding * 2)

    Process {
        id: settingsProc
        command: ["blueman-manager"]
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: Settings.popupPadding
        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true

        Column {
            id: content
            width: parent.width
            spacing: 10

            Item {
                width: parent.width
                height: Settings.pillHeight

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.primary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                    text: "Bluetooth"
                }

                ActionButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    label: Bluetooth.enabled ? "Disable" : "Enable"
                    accent: true
                    onClicked: Bluetooth.toggle()
                }
            }

            Row {
                spacing: 8

                ActionButton {
                    label: Bluetooth.discovering ? "Stop scan" : "Scan"
                    active: Bluetooth.discovering
                    onClicked: {
                        Bluetooth.setDiscovery(!Bluetooth.discovering);
                    }
                }

                ActionButton {
                    label: "Settings"
                    onClicked: settingsProc.running = true
                }
            }

            Text {
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                text: Bluetooth.tooltip
                wrapMode: Text.Wrap
                width: parent.width
            }

            Repeater {
                model: Bluetooth.sortedDevices()

                Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 44
                    radius: 8
                    color: area.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            text: modelData.deviceName || modelData.name || "Device"
                        }

                        Text {
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                            text: (modelData.connected ? "connected" : modelData.paired ? "paired" : "new") + "  " + modelData.address
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 6
                        spacing: 4

                        ActionButton {
                            label: modelData.connected ? "Disconnect" : "Connect"
                            accent: !modelData.connected
                            onClicked: modelData.connected ? Bluetooth.disconnect(modelData) : Bluetooth.connect(modelData)
                        }

                        ActionButton {
                            label: "Forget"
                            visible: modelData.paired || modelData.connected
                            onClicked: Bluetooth.forget(modelData)
                        }
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        z: -1
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
