import QtQuick
import Quickshell
import qs.components
import qs.config

Pill {
    id: root
    tooltip: "Click: calendar  Right click: date format"

    property date now: new Date()

    function pad(value) {
        return value < 10 ? "0" + value : "" + value;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.now = new Date()
    }

    Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: UIState.clockAlt
            ? "  " + Qt.formatDate(root.now, "ddd, dd MMM yyyy")
            : "  " + root.pad(root.now.getHours()) + ":" + root.pad(root.now.getMinutes()) + ":" + root.pad(root.now.getSeconds())
    }

    onClicked: {
        UIState.resetCalendar();
        UIState.open("calendar");
    }
    onRightClicked: UIState.toggleClockAlt()
}
