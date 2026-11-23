import QtQuick
import qs.components
import qs.config
import Quickshell.Io
import Quickshell.Networking as NetworkingApi
import qs.services

Glass {
    id: root
    width: 350
    height: Math.min(480, content.implicitHeight + Settings.popupPadding * 2)

    property string password: ""

    Process {
        id: settingsProc
        command: ["nm-connection-editor"]
    }

    Component.onCompleted: Network.startScan()
    Component.onDestruction: Network.stopScan()

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
                    text: "Network"
                }

                ActionButton {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    label: Network.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"
                    active: Network.wifiEnabled
                    accent: !Network.wifiEnabled
                    onClicked: Network.toggleWifi()
                }
            }

            Row {
                spacing: 8

                ActionButton {
                    label: "Scan"
                    onClicked: Network.startScan()
                }

                ActionButton {
                    label: "Disconnect"
                    visible: !!Network.activeNetwork
                    onClicked: Network.disconnect()
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
                text: "Active: " + Network.tooltip
                width: parent.width
                wrapMode: Text.Wrap
            }

            Rectangle {
                width: parent.width
                height: 34
                radius: 8
                color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.06)

                TextInput {
                    id: passwordField
                    anchors.fill: parent
                    anchors.margins: 8
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    echoMode: TextInput.Password
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 8
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    text: "Password for new Wi-Fi"
                    visible: passwordField.text.length === 0
                }
            }

            Repeater {
                model: Network.networkList

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
                            color: modelData.connected ? Theme.primary : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            text: (modelData.connected ? "● " : "") + modelData.name
                        }

                        Text {
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 4
                            text: Math.round(modelData.signalStrength) + "%  " + NetworkingApi.WifiSecurityType.toString(modelData.security)
                        }
                    }

                    ActionButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 6
                        label: modelData.connected ? "Connected" : modelData.known ? "Connect" : "Join"
                        accent: !modelData.connected
                        onClicked: {
                            if (!modelData.connected) Network.connect(modelData, passwordField.text);
                            passwordField.text = "";
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
