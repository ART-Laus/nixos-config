pragma Singleton
import QtQuick
import Quickshell.Io
import qs.config

Item {
    id: root

    property real cpuUsage: 0
    property real memoryUsage: 0
    property real temperature: 0
    property string layout: "US"
    property int brightness: 0
    property int brightnessMax: 1

    readonly property string cpuText: Math.round(cpuUsage) + "% 󰍛"
    readonly property string memoryText: Math.round(memoryUsage) + "% 󰍛"
    readonly property string brightnessText: " " + brightness + "%"

    property real lastCpuTotal: 0
    property real lastCpuIdle: 0
    property int pendingBrightness: -1

    function parseMemory(text) {
        function field(key) {
            var match = text.match(new RegExp("^" + key + ":\\s+(\\d+)", "m"));
            return match ? Number(match[1]) : 0;
        }
        var total = field("MemTotal");
        var available = field("MemAvailable");
        if (!available) available = field("MemFree");
        memoryUsage = total > 0 ? Math.max(0, Math.min(100, (total - available) / total * 100)) : 0;
    }

    function parseCpu(text) {
        var line = text.split("\n")[0] || "";
        var parts = line.trim().split(/\s+/).slice(1).map(Number);
        if (parts.length < 4) return;
        var total = 0;
        for (var i = 0; i < parts.length; i++) total += parts[i];
        var idle = parts[3] + (parts.length > 4 ? parts[4] : 0);
        if (lastCpuTotal > 0) {
            var totalDelta = total - lastCpuTotal;
            var idleDelta = idle - lastCpuIdle;
            cpuUsage = totalDelta > 0 ? Math.max(0, Math.min(100, (1 - idleDelta / totalDelta) * 100)) : 0;
        }
        lastCpuTotal = total;
        lastCpuIdle = idle;
    }

    function parseTemperature(text) {
        var value = Number(text.trim());
        temperature = isFinite(value) ? value / 1000 : 0;
    }

    function parseLayout(text) {
        try {
            var data = JSON.parse(text);
            var keyboards = data.keyboards || [];
            for (var i = 0; i < keyboards.length; i++) {
                var keyboard = keyboards[i];
                if (keyboard.name !== Settings.layoutDevice) continue;
                var keymap = String(keyboard.active_keymap || "");
                if (/russian|ru/i.test(keymap)) layout = "RU";
                else if (/english|united states|us/i.test(keymap)) layout = "US";
                else layout = keymap.slice(0, 2).toUpperCase() || "US";
                return;
            }
        } catch (error) {
            layout = "US";
        }
    }

    function parseBrightness(text) {
        var fields = text.trim().split(",");
        if (fields.length < 5) return;
        var percent = parseInt(String(fields[3]).replace("%", ""), 10);
        var maximum = parseInt(fields[4], 10);
        if (isFinite(percent)) brightness = Math.max(0, Math.min(100, percent));
        if (isFinite(maximum) && maximum > 0) brightnessMax = maximum;
    }

    function refreshBrightness() {
        if (!brightnessProc.running) brightnessProc.running = true;
    }

    function refreshLayout() {
        if (!layoutProc.running) layoutProc.running = true;
    }

    function setBrightness(value) {
        var next = Math.max(0, Math.min(100, Math.round(value)));
        pendingBrightness = next;
        brightnessSetter.running = true;
        UIState.showOsd("  " + next + "%");
    }

    function stepBrightness(delta) {
        setBrightness(brightness + delta);
    }

    FileView {
        id: memoryView
        path: "/proc/meminfo"
        printErrors: false
        onLoaded: root.parseMemory(memoryView.text())
        onTextChanged: root.parseMemory(memoryView.text())
    }

    FileView {
        id: cpuView
        path: "/proc/stat"
        printErrors: false
        onLoaded: root.parseCpu(cpuView.text())
        onTextChanged: root.parseCpu(cpuView.text())
    }

    FileView {
        id: temperatureView
        path: "/sys/class/thermal/thermal_zone0/temp"
        printErrors: false
        onLoaded: root.parseTemperature(temperatureView.text())
        onTextChanged: root.parseTemperature(temperatureView.text())
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            memoryView.reload();
            cpuView.reload();
            temperatureView.reload();
        }
    }

    Process {
        id: layoutProc
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.parseLayout(text)
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            if (!layoutProc.running) layoutProc.running = true;
        }
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: root.parseBrightness(text)
        }
    }

    Process {
        id: brightnessSetter
        command: ["brightnessctl", "set", root.pendingBrightness + "%"]
        onRunningChanged: {
            if (!running && root.pendingBrightness >= 0) {
                root.pendingBrightness = -1;
                root.refreshBrightness();
            }
        }
    }

    Component.onCompleted: {
        memoryView.reload();
        cpuView.reload();
        temperatureView.reload();
        layoutProc.running = true;
        root.refreshBrightness();
    }
}
