import QtQuick
import qs.config
import qs.clipboard.core
import "../core/Format.js" as Format

Rectangle {
    id: root

    property var entry: ({})
    property string query: ""
    property bool selected: false
    property bool copied: false
    property bool hovered: false

    signal activate(int id)
    signal pin(int id, bool pinned)
    signal remove(int id)
    signal details(int id)

    width: parent ? parent.width : 0
    height: ClipboardTheme.cardHeight
    radius: ClipboardTheme.cardRadius
    color: selected ? ClipboardTheme.cardHover : ClipboardTheme.card
    border.color: root.entry.pinned
        ? Qt.rgba(ClipboardTheme.secondary.r, ClipboardTheme.secondary.g, ClipboardTheme.secondary.b, 0.45)
        : selected ? Qt.rgba(ClipboardTheme.accent.r, ClipboardTheme.accent.g, ClipboardTheme.accent.b, 0.42) : ClipboardTheme.border
    border.width: 1

    Behavior on color { ColorAnimation { duration: ClipboardTheme.fast } }
    Behavior on border.color { ColorAnimation { duration: ClipboardTheme.fast } }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        z: 1
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.activate(Number(root.entry.id))
    }

    // Left edge: quiet visual difference for pinned entries.
    Rectangle {
        visible: !!root.entry.pinned
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        radius: 1
        color: ClipboardTheme.secondary
        opacity: 0.65
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        anchors.topMargin: 9
        anchors.bottomMargin: 9
        z: 2

        Column {
            anchors.left: parent.left
            anchors.right: actionColumn.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Row {
                spacing: 6

                Rectangle {
                    width: badgeText.implicitWidth + 12
                    height: 16
                    radius: 8
                    color: root.entry.kind === "image"
                        ? Qt.rgba(ClipboardTheme.secondary.r, ClipboardTheme.secondary.g, ClipboardTheme.secondary.b, 0.16)
                        : Qt.rgba(ClipboardTheme.emerald.r, ClipboardTheme.emerald.g, ClipboardTheme.emerald.b, 0.14)
                    Text {
                        id: badgeText
                        text: Format.kindLabel(root.entry.kind)
                        color: root.entry.kind === "image" ? ClipboardTheme.secondary : ClipboardTheme.emerald
                        font.pixelSize: Theme.fontSize - 5
                        font.family: Theme.fontFamily
                        font.letterSpacing: 0.8
                        anchors.centerIn: parent
                    }
                }

                Text {
                    visible: !!root.entry.pinned
                    text: "★"
                    color: ClipboardTheme.secondary
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    visible: !!root.entry.domain
                    text: root.entry.domain
                    color: ClipboardTheme.muted
                    font.pixelSize: Theme.fontSize - 4
                    font.family: Theme.fontFamily
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                }
            }

            Item {
                width: parent.width
                height: 34

                Image {
                    id: thumbnail
                    visible: root.entry.kind === "image" && !!root.entry.thumbPath
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 92
                    height: 30
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: true
                    source: root.entry.thumbPath || ""
                }

                Rectangle {
                    id: swatch
                    visible: root.entry.kind === "color"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 26
                    height: 26
                    radius: 6
                    border.color: ClipboardTheme.border
                    color: {
                        var value = String(root.entry.color || "");
                        if (/^#(?:[0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$/i.test(value))
                            return value;
                        return ClipboardTheme.surface;
                    }
                }

                Text {
                    id: previewText
                    visible: root.entry.kind !== "image"
                    anchors.left: root.entry.kind === "color" ? swatch.right : parent.left
                    anchors.leftMargin: root.entry.kind === "color" ? 10 : 0
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: Format.highlight(String(root.entry.preview || ""), root.query)
                    textFormat: Text.RichText
                    color: ClipboardTheme.text
                    font.pixelSize: Theme.fontSize - 1
                    font.family: root.entry.kind === "code" || root.entry.kind === "json"
                        ? ClipboardTheme.monoFont : Theme.fontFamily
                    wrapMode: Text.WrapAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    lineHeight: 1.05
                }

                Text {
                    visible: root.entry.kind === "image"
                    anchors.left: thumbnail.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.entry.thumbPath ? String(Math.round(root.entry.bytes / 1024)) + " KB preview" : "Image"
                    color: ClipboardTheme.textDim
                    font.pixelSize: Theme.fontSize - 2
                    font.family: Theme.fontFamily
                }
            }
        }

        Column {
            id: actionColumn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: Format.relativeTime(root.entry.createdAt)
                color: ClipboardTheme.muted
                font.pixelSize: Theme.fontSize - 4
                font.family: Theme.fontFamily
                anchors.right: parent.right
            }

            Row {
                anchors.right: parent.right
                spacing: 2

                Text {
                    property bool actionHovered: pinArea.containsMouse
                    text: root.entry.pinned ? "★" : "☆"
                    color: actionHovered || root.entry.pinned ? ClipboardTheme.secondary : ClipboardTheme.muted
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                    opacity: root.hovered || root.entry.pinned ? 1 : 0.35

                    Behavior on opacity { NumberAnimation { duration: ClipboardTheme.fast } }
                    Behavior on color { ColorAnimation { duration: ClipboardTheme.fast } }

                    MouseArea {
                        id: pinArea
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        z: 3
                        onClicked: {
                            mouse.accepted = true;
                            root.pin(Number(root.entry.id), !root.entry.pinned);
                        }
                    }
                }

                Text {
                    property bool actionHovered: copyArea.containsMouse
                    visible: root.hovered
                    text: "⧉"
                    color: actionHovered ? ClipboardTheme.accent : ClipboardTheme.muted
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily

                    MouseArea {
                        id: copyArea
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        z: 3
                        onClicked: {
                            mouse.accepted = true;
                            root.activate(Number(root.entry.id));
                        }
                    }
                }

                Text {
                    property bool actionHovered: expandArea.containsMouse
                    visible: root.hovered
                    text: "⤢"
                    color: actionHovered ? ClipboardTheme.text : ClipboardTheme.muted
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily

                    MouseArea {
                        id: expandArea
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        z: 3
                        onClicked: {
                            mouse.accepted = true;
                            root.details(Number(root.entry.id));
                        }
                    }
                }

                Text {
                    property bool actionHovered: deleteArea.containsMouse
                    text: "×"
                    color: actionHovered ? ClipboardTheme.emerald : ClipboardTheme.muted
                    font.pixelSize: Theme.fontSize + 1
                    font.family: Theme.fontFamily
                    opacity: root.hovered ? 1 : 0.25

                    Behavior on opacity { NumberAnimation { duration: ClipboardTheme.fast } }
                    Behavior on color { ColorAnimation { duration: ClipboardTheme.fast } }

                    MouseArea {
                        id: deleteArea
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        z: 3
                        onClicked: {
                            mouse.accepted = true;
                            root.remove(Number(root.entry.id));
                        }
                    }
                }
            }
        }
    }

    // Immediate, quiet feedback: the card pulses at the same moment the
    // restore command is sent (no artificial delay before copying).
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: ClipboardTheme.accent
        opacity: root.copied ? 0.12 : 0
        z: 4

        Behavior on opacity { NumberAnimation { duration: ClipboardTheme.normal } }
    }
}
