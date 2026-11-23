import QtQuick
import qs.components
import qs.config
import qs.services

Glass {
    id: root
    width: 340
    height: Math.min(480, content.implicitHeight + Settings.popupPadding * 2)

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

            Text {
                color: Theme.primary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                text: "Audio"
            }

            Row {
                spacing: 8
                width: parent.width

                ActionButton {
                    label: Audio.sinkMuted ? "Unmute" : "Mute"
                    accent: true
                    onClicked: Audio.toggleSinkMute()
                }

                ActionButton {
                    label: "-"
                    onClicked: Audio.setSinkVolume(Audio.sinkVolume - Settings.volumeStep)
                }

                ActionButton {
                    label: "+"
                    onClicked: Audio.setSinkVolume(Audio.sinkVolume + Settings.volumeStep)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    text: Audio.sinkVolume + "%"
                }
            }

            MiniSlider {
                width: parent.width
                from: 0
                to: 150
                value: Audio.sinkVolume
                onValueChanged: {
                    if (Math.abs(value - Audio.sinkVolume) > 0.5) Audio.setSinkVolume(value);
                }
            }

            Text {
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                text: "OUTPUT"
            }

            Repeater {
                model: Audio.sinks

                Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 30
                    radius: 8
                    color: area.containsMouse || (Audio.sink && modelData === Audio.sink)
                        ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12)
                        : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        color: Audio.sink && modelData === Audio.sink ? Theme.primary : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        text: (Audio.sink && modelData === Audio.sink ? "● " : "") + (modelData.description || modelData.name)
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Audio.selectSink(modelData)
                    }
                }
            }

            Text {
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                text: "INPUT"
            }

            Row {
                spacing: 8
                width: parent.width

                ActionButton {
                    label: Audio.sourceMuted ? "Unmute mic" : "Mute mic"
                    onClicked: Audio.toggleSourceMute()
                }

                MiniSlider {
                    width: parent.width - 120
                    from: 0
                    to: 150
                    value: Audio.sourceVolume
                    onValueChanged: {
                        if (Math.abs(value - Audio.sourceVolume) > 0.5) Audio.setSourceVolume(value);
                    }
                }
            }

            Repeater {
                model: Audio.sources

                Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 30
                    radius: 8
                    color: area.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        text: modelData.description || modelData.name
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Audio.selectSource(modelData)
                    }
                }
            }

            Text {
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                text: "STREAMS"
                visible: Audio.streams.length > 0
            }

            Repeater {
                model: Audio.streams

                Column {
                    required property var modelData
                    width: parent.width
                    spacing: 4
                    visible: modelData.audio

                    Row {
                        width: parent.width

                        Text {
                            width: parent.width - 60
                            elide: Text.ElideRight
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 3
                            text: modelData.properties["application.name"] || modelData.description || modelData.name
                        }

                        ActionButton {
                            label: modelData.audio && modelData.audio.muted ? "Unmute" : "Mute"
                            onClicked: Audio.toggleNodeMute(modelData)
                        }
                    }

                    MiniSlider {
                        width: parent.width
                        value: modelData.audio ? modelData.audio.volume * 100 : 0
                        onValueChanged: {
                            if (modelData.audio && Math.abs(value - modelData.audio.volume * 100) > 0.5) Audio.setNodeVolume(modelData, value);
                        }
                    }
                }
            }
        }
    }
}
