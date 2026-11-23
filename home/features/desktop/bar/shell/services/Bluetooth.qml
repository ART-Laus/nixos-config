pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.config

Item {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: !!adapter
    readonly property bool enabled: !!adapter && adapter.enabled
    readonly property bool discovering: !!adapter && adapter.discovering
    readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property var connectedDevices: {
        var result = [];
        for (var i = 0; i < devices.length; i++) {
            if (devices[i] && devices[i].connected) result.push(devices[i]);
        }
        return result;
    }

    readonly property string text: {
        if (!adapter || !adapter.enabled) return "";
        return connectedDevices.length > 0 ? " " + connectedDevices.length : "";
    }

    readonly property string tooltip: {
        if (!adapter) return "Bluetooth unavailable";
        if (!adapter.enabled) return "Bluetooth disabled";
        if (connectedDevices.length === 0) return "Bluetooth on";
        var names = [];
        for (var i = 0; i < connectedDevices.length; i++) {
            names.push(connectedDevices[i].deviceName || connectedDevices[i].name || "Device");
        }
        return names.join(", ");
    }

    function toggle() {
        if (!adapter) return;
        adapter.enabled = !adapter.enabled;
        UIState.showOsd(adapter.enabled ? "  on" : "  off");
    }

    function setDiscovery(active) {
        if (!adapter || !adapter.enabled) return;
        adapter.discovering = active;
    }

    function connect(device) {
        if (!device || device.connected) return;
        if (!device.paired) device.pair();
        device.connect();
    }

    function disconnect(device) {
        if (!device || !device.connected) return;
        device.disconnect();
    }

    function forget(device) {
        if (!device) return;
        device.forget();
    }

    function sortedDevices() {
        var result = devices.slice();
        result.sort(function (a, b) {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            if (a.paired !== b.paired) return a.paired ? -1 : 1;
            return String(a.deviceName || a.name || "").localeCompare(String(b.deviceName || b.name || ""));
        });
        return result;
    }
}
