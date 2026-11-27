import QtQuick
import qs.config
import qs.scripthub
import qs.notifications

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
    implicitHeight: 31
    radius: NotificationTokens.radiusControl
    color: NotificationTokens.canvas
    border.width: 1
    border.color: input.activeFocus ? NotificationTokens.alpha(NotificationTokens.mint, 0.52) : NotificationTokens.divider

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 9
        anchors.rightMargin: 9
        verticalAlignment: TextInput.AlignVCenter
        color: NotificationTokens.text
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
        color: NotificationTokens.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        text: root.placeholder
        visible: input.text.length === 0 && !input.activeFocus
    }

    Behavior on border.color { ColorAnimation { duration: NotificationTokens.motionFast } }
}
