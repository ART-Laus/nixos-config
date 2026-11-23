import QtQuick
import qs.config
import qs.appcenter.core
import qs.appcenter.services
import qs.appcenter.components

Item {
    id: root

    property var results: []
    property int currentIndex: -1
    readonly property int visibleRows: 1
    readonly property int visibleColumns: 3
    readonly property int gridRowHeight: 112
    readonly property int gridCellWidth: 156
    readonly property var recentEntries: AppState.query.length === 0 ? ApplicationsService.recent() : []

    function recompute() {
        root.results = ApplicationsService.filtered(AppState.query);
        if (root.results.length > 0 && root.currentIndex < 0)
            root.currentIndex = 0;
        if (root.currentIndex >= root.results.length)
            root.currentIndex = root.results.length - 1;
    }

    function move(delta) {
        if (root.results.length === 0)
            return;
        var columns = grid.columns > 0 ? grid.columns : 1;
        var next = root.currentIndex + delta;
        if (next < 0)
            next = 0;
        if (next >= root.results.length)
            next = root.results.length - 1;
        root.currentIndex = next;
        grid.positionViewAtIndex(next, GridView.Contain);
    }

    function movePage(delta) {
        var columns = grid.columns > 0 ? grid.columns : 1;
        root.move(delta * columns);
    }

    function activateCurrent() {
        if (root.currentIndex < 0 || root.currentIndex >= root.results.length)
            return;
        ApplicationsService.launch(root.results[root.currentIndex].entry);
    }

    function closeOverlays() {
        contextMenu.visible = false;
    }

    Component.onCompleted: root.recompute()

    Connections {
        target: AppState
        function onQueryChanged() {
            root.currentIndex = -1;
            root.recompute();
        }
    }

    Connections {
        target: UsageStore
        function onUsageChanged() {
            root.recompute();
        }
    }

    Connections {
        target: ApplicationsService
        function onCatalogChanged() {
            root.recompute();
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        SectionHeader {
            visible: root.recentEntries.length > 0
            title: "Recently Used"
            subtitle: root.recentEntries.length + " apps"
        }

        Row {
            visible: root.recentEntries.length > 0
            width: parent.width
            height: 104
            spacing: 10
            clip: true

            Repeater {
                model: root.recentEntries

                AppCard {
                    entry: modelData
                    width: 118
                    height: 104
                    indices: []
                    highlighted: false
                    onActivate: ApplicationsService.launch(entry)
                    onContextRequested: function (mouse) {
                        root.showContext(entry, mouse, false);
                    }
                }
            }
        }

        SectionHeader {
            title: AppState.query.length > 0 ? "Results" : "All Applications"
            subtitle: root.results.length + " apps"
        }

        Item {
            width: parent.width
            height: Math.min(Math.max(0, parent.height - (root.recentEntries.length > 0 ? 190 : 70)), root.gridRowHeight * root.visibleRows)

            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                cellWidth: grid.columns === 1 ? grid.width : grid.width / grid.columns
                cellHeight: root.gridRowHeight
                model: root.results.length
                currentIndex: root.currentIndex
                highlight: Rectangle {
                    color: "transparent"
                    border.color: Theme.primary
                    border.width: 1
                    radius: AppSettings.cardRadius
                    z: 2
                }

                property int columns: root.visibleColumns

                Component.onCompleted: function () {
                    AppState.appGridColumns = grid.columns;
                    AppState.appGridCellWidth = grid.cellWidth;
                }

                onCellWidthChanged: AppState.appGridCellWidth = grid.cellWidth

                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    AppCard {
                        property var result: root.results[index]
                        entry: result ? result.entry : null
                        anchors.centerIn: parent
                        width: Math.min(118, grid.cellWidth - 12)
                        height: 104
                        indices: result ? result.indices : []
                        highlighted: index === root.currentIndex
                        onActivate: {
                            root.currentIndex = index;
                            if (entry)
                                ApplicationsService.launch(entry);
                        }
                        onContextRequested: function (mouse) {
                            if (entry)
                                root.showContext(entry, mouse, true);
                        }
                    }
                }
            }

            EmptyState {
                visible: root.results.length === 0
                anchors.centerIn: parent
                title: "Nothing found"
                message: "Try a different name, category or keyword"
            }
        }
    }

    ContextMenu {
        id: contextMenu
        parent: root
        onActionRequested: function (action) {
            var entry = contextMenu.entry;
            if (action === "launch")
                ApplicationsService.launch(entry);
            else
                ApplicationsService.launchAction(entry, action);
        }
        property var entry: null
    }

    function showContext(entry, mouse, includeActions) {
        var items = [{ label: "Launch", action: "launch" }];
        if (includeActions && entry && entry.actions) {
            for (var i = 0; i < entry.actions.length; i++)
                items.push({ label: entry.actions[i].name || entry.actions[i].id, action: entry.actions[i].id });
        }
        contextMenu.entry = entry;
        contextMenu.items = items;
        contextMenu.x = Math.min(mouse.x, root.width - contextMenu.width - 8);
        contextMenu.y = Math.min(mouse.y, root.height - contextMenu.height - 8);
        contextMenu.visible = true;
    }
}
