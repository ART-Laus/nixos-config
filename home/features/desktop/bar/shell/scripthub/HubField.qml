import QtQuick
import qs.config

Rectangle {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property bool password: false
    property bool numeric: false
    property bool readOnly: false
    property int minimumWidth: 120
    signal accepted()
    signal textEdited(string value)

    implicitWidth: Math.max(minimumWidth, 160)
    implicitHeight: 30
    radius: 8
    color: Qt.rgba(0, 0, 0, 0.28)
    border.width: 1
    border.color: input.activeFocus ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.5)
        : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.10)

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 9
        anchors.rightMargin: 9
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        echoMode: root.password ? TextInput.Password : TextInput.Normal
        readOnly: root.readOnly
        validator: root.numeric ? numericValidator : null
        onAccepted: root.accepted()
        onTextEdited: root.textEdited(text)

        IntValidator {
            id: numericValidator
            bottom: -2147483647
            top: 2147483647
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        text: root.placeholder
        visible: input.text.length === 0 && !input.activeFocus
    }
}
