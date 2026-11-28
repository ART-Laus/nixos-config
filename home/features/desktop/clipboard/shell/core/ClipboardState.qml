pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool open: false
    property string screenName: ""
    property string query: ""
    property string category: "all"
    property int copiedId: 0
    property int detailId: 0
    property string confirmAction: ""
    property string toast: ""
    property int selectedId: 0

    signal opened()
    signal closed()

    function openOn(screen) {
        root.screenName = screen;
        root.open = true;
        root.opened();
    }

    function close() {
        if (!root.open)
            return;
        root.open = false;
        root.detailId = 0;
        root.confirmAction = "";
        root.closed();
    }

    function setCategory(value) {
        root.category = value;
    }

    function clearQuery() {
        root.query = "";
    }

    function notify(message) {
        root.toast = message;
    }
}
