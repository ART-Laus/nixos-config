import QtQuick
import qs.config

Rectangle {
    id: root
    property var items: []
    signal actionRequested(string action)

    function close() {
        visible = false
    }

    visible: false
    z: 1000
    radius: AppSettings.surfaceRadius
    color: Theme.tooltip
    border.color: Theme.pill
    border.width: 1
    width: 220
    height: content.implicitHeight + 12
    clip: true

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 6
        spacing: 2

        Repeater {
            model: root.items || []

            Rectangle {
                required property var modelData
                readonly property bool danger: !!modelData.danger
                readonly property bool disabled: !!modelData.disabled
                readonly property bool checkable: !!modelData.checkable
                readonly property bool checked: !!modelData.checked
                readonly property string label: modelData.label || ""
                readonly property string action: modelData.action || ""

                width: content.width
                height: 30
                radius: AppSettings.cardRadius
                color: itemMouse.containsMouse && !disabled ? Theme.pillHover : "transparent"
                opacity: disabled ? 0.45 : 1

                Behavior on color {
                    ColorAnimation { duration: AppSettings.transitionFast }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: (parent.checkable ? (parent.checked ? "✓ " : "  ") : "") + parent.label
                    color: parent.danger ? Theme.error : Theme.text
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !parent.disabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        root.actionRequested(parent.action)
                        root.close()
                    }
                }
            }
        }
    }
}
