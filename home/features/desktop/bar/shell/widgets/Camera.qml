import QtQuick
import Quickshell.Io
import qs.components
import qs.config

Pill {
    id: root
    tooltip: root.active ? "Камера — выключить окно" : "Камера — включить"

    Process {
        id: cameraProc
        command: ["camera-mirror"]

        onStarted: root.active = true
        onExited: function () { root.active = false; }
    }

    Text {
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        text: "CAM"
    }

    onClicked: {
        if (cameraProc.running) {
            // Второй клик закрывает окно. Камера в EC остаётся включённой,
            // поэтому следующее открытие не ждёт перечисления USB.
            cameraProc.running = false;
            root.active = false;
        } else {
            // Сразу даём визуальный отклик, не дожидаясь запуска mpv.
            root.active = true;
            cameraProc.running = true;
        }
    }
}
