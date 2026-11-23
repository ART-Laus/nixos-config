import QtQuick
import qs.components
import qs.config

Glass {
    id: root
    width: 300
    height: 300

    readonly property int firstOffset: {
        var first = new Date(UIState.calendarYear, UIState.calendarMonth, 1);
        return (first.getDay() + 6) % 7;
    }
    readonly property int dayCount: new Date(UIState.calendarYear, UIState.calendarMonth + 1, 0).getDate()
    readonly property string monthName: Qt.formatDate(new Date(UIState.calendarYear, UIState.calendarMonth, 1), "MMMM yyyy")

    Column {
        anchors.fill: parent
        anchors.margins: Settings.popupPadding
        spacing: 10

        Item {
            width: parent.width
            height: Settings.pillHeight

            ActionButton {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                label: "‹"
                onClicked: UIState.shiftCalendar(-1)
            }

            Text {
                anchors.centerIn: parent
                color: Theme.primary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                text: root.monthName
            }

            ActionButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                label: "›"
                onClicked: UIState.shiftCalendar(1)
            }
        }

        Grid {
            width: parent.width
            columns: 7
            spacing: 4

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                Text {
                    width: (root.width - Settings.popupPadding * 2 - 24) / 7
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    text: modelData
                }
            }
        }

        Grid {
            width: parent.width
            columns: 7
            spacing: 4

            Repeater {
                model: root.firstOffset + root.dayCount

                Rectangle {
                    required property int index
                    property int day: index >= root.firstOffset ? index - root.firstOffset + 1 : 0
                    property bool today: {
                        if (!day) return false;
                        var now = new Date();
                        return day === now.getDate()
                            && UIState.calendarMonth === now.getMonth()
                            && UIState.calendarYear === now.getFullYear();
                    }

                    width: (root.width - Settings.popupPadding * 2 - 24) / 7
                    height: 28
                    radius: 8
                    color: today ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        color: today ? Theme.primary : day ? Theme.text : "transparent"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        text: day || "-"
                    }
                }
            }
        }
    }
}
