pragma Singleton
import QtQuick

QtObject {
    id: root

    property string activePopup: ""
    property var barWindow: null
    property string osdText: ""
    property bool clockAlt: false
    property int calendarMonth: new Date().getMonth()
    property int calendarYear: new Date().getFullYear()

    function open(id) {
        if (root.activePopup === id) {
            root.close(id);
            return;
        }
        root.activePopup = id;
    }

    function close(id) {
        if (root.activePopup === id) root.activePopup = "";
    }

    function closeAll() {
        root.activePopup = "";
    }

    function showOsd(text) {
        root.osdText = text;
    }

    function toggleClockAlt() {
        root.clockAlt = !root.clockAlt;
    }

    function shiftCalendar(months) {
        var date = new Date(root.calendarYear, root.calendarMonth + months, 1);
        root.calendarMonth = date.getMonth();
        root.calendarYear = date.getFullYear();
    }

    function resetCalendar() {
        var now = new Date();
        root.calendarMonth = now.getMonth();
        root.calendarYear = now.getFullYear();
    }
}
