import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.components
import qs.config

Pill {
    id: root
    padding: 7
    spacing: 5

    Repeater {
        model: SystemTray.items.values

        Image {
            required property var modelData
            source: modelData.icon
            width: root.iconSize
            height: root.iconSize
            fillMode: Image.PreserveAspectFit
            smooth: true

            MouseArea {
                anchors.fill: parent
                anchors.margins: -3
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: function (mouse) {
                    if (mouse.button === Qt.LeftButton) parent.modelData.activate();
                    else if (mouse.button === Qt.MiddleButton) parent.modelData.secondaryActivate();
                    else {
                        var window = UIState.barWindow || parent;
                        var globalPoint = parent.mapToGlobal(Qt.point(0, 0));
                        var offsetX = window && window.x !== undefined ? window.x : 0;
                        var offsetY = window && window.y !== undefined ? window.y : 0;
                        parent.modelData.display(window, Math.round(globalPoint.x - offsetX), Math.round(globalPoint.y - offsetY));
                    }
                }
            }
        }
    }
}
