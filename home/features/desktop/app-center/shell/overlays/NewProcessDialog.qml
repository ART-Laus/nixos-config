import QtQuick
import qs.config
import qs.appcenter.services

Rectangle {
    id: root

    signal closed()

    visible: false
    z: 2000
    width: 480
    height: 316
    radius: AppSettings.surfaceRadius
    color: Theme.tooltip
    border.color: Theme.pill
    border.width: 1

    function tokenize(text) {
        var out = [];
        var current = "";
        var quote = "";
        var escaped = false;
        var source = text === null || text === undefined ? "" : String(text);
        for (var i = 0; i < source.length; i++) {
            var ch = source.charAt(i);
            if (escaped) {
                current += ch;
                escaped = false;
            } else if (ch === "\\") {
                escaped = true;
            } else if (quote) {
                if (ch === quote)
                    quote = "";
                else
                    current += ch;
            } else if (ch === "\"" || ch === "'") {
                quote = ch;
            } else if (ch === " ") {
                if (current.length > 0) {
                    out.push(current);
                    current = "";
                }
            } else {
                current += ch;
            }
        }
        if (current.length > 0)
            out.push(current);
        return out;
    }

    function run() {
        var command = commandInput.text.trim();
        var cwd = cwdInput.text.trim();
        if (command.length === 0)
            return;
        if (shellCheck.checked) {
            var full = command;
            if (argsInput.text.trim().length > 0)
                full += " " + argsInput.text.trim();
            ProcessService.startShell(full, cwd);
        } else {
            ProcessService.startProcess([command].concat(tokenize(argsInput.text)), cwd);
        }
        root.visible = false;
        root.closed();
    }

    Text {
        id: title
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        text: shellCheck.checked ? "New Shell Command" : "New Process"
        color: Theme.text
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
        font.family: Theme.fontFamily
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.topMargin: 14
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 9

        Rectangle {
            width: parent.width
            height: 38
            radius: AppSettings.cardRadius
            color: Theme.pill
            border.color: commandInput.activeFocus ? Theme.primary : Theme.pill

            TextInput {
                id: commandInput
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                color: Theme.text
                selectionColor: Theme.primaryDim
                selectedTextColor: Theme.text
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                verticalAlignment: TextInput.AlignVCenter
                wrapMode: TextInput.NoWrap
            }
            Text {
                visible: commandInput.text.length === 0
                anchors.left: commandInput.left
                anchors.verticalCenter: commandInput.verticalCenter
                text: shellCheck.checked ? "shell command" : "program"
                color: Theme.textDim
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
            }
        }

        Rectangle {
            width: parent.width
            height: 38
            radius: AppSettings.cardRadius
            color: Theme.pill
            border.color: argsInput.activeFocus ? Theme.primary : Theme.pill

            TextInput {
                id: argsInput
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                color: Theme.text
                selectionColor: Theme.primaryDim
                selectedTextColor: Theme.text
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                verticalAlignment: TextInput.AlignVCenter
                wrapMode: TextInput.NoWrap
            }
            Text {
                visible: argsInput.text.length === 0
                anchors.left: argsInput.left
                anchors.verticalCenter: argsInput.verticalCenter
                text: "arguments"
                color: Theme.textDim
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
            }
        }

        Rectangle {
            width: parent.width
            height: 38
            radius: AppSettings.cardRadius
            color: Theme.pill
            border.color: cwdInput.activeFocus ? Theme.primary : Theme.pill

            TextInput {
                id: cwdInput
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                color: Theme.text
                selectionColor: Theme.primaryDim
                selectedTextColor: Theme.text
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                verticalAlignment: TextInput.AlignVCenter
                wrapMode: TextInput.NoWrap
            }
            Text {
                visible: cwdInput.text.length === 0
                anchors.left: cwdInput.left
                anchors.verticalCenter: cwdInput.verticalCenter
                text: "working directory (optional)"
                color: Theme.textDim
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
            }
        }

        Row {
            spacing: 9
            Rectangle {
                id: shellCheck
                property bool checked: false
                width: 16
                height: 16
                radius: 4
                color: checked ? Theme.primaryDim : "transparent"
                border.color: checked ? Theme.primary : Theme.textDim
                border.width: 1
                Text {
                    visible: parent.checked
                    anchors.centerIn: parent
                    text: "✓"
                    color: Theme.text
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: parent.checked = !parent.checked
                }
            }
            Text {
                text: "Shell Command (pipes and redirects)"
                color: Theme.textDim
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
                anchors.verticalCenter: parent.children[0].verticalCenter
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16
        spacing: 8

        Rectangle {
            width: 86
            height: 30
            radius: 15
            color: cancelMouse.containsMouse ? Theme.pillHover : "transparent"
            Text {
                anchors.centerIn: parent
                text: "Cancel"
                color: Theme.textDim
                font.pixelSize: Theme.fontSize - 1
                font.family: Theme.fontFamily
            }
            MouseArea {
                id: cancelMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.visible = false;
                    root.closed();
                }
            }
        }
        Rectangle {
            width: 86
            height: 30
            radius: 15
            color: Theme.primaryDim
            Text {
                anchors.centerIn: parent
                text: "Run"
                color: Theme.text
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
                font.family: Theme.fontFamily
            }
            MouseArea {
                id: runMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.run()
            }
        }
    }

    onVisibleChanged: function () {
        if (visible)
            commandInput.forceActiveFocus();
    }
}
