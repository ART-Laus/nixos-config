pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking
import qs.config

Item {
    id: root

    property var devices: []
    property var primaryDevice: null
    property var wifiDevice: null
    property var wiredDevice: null
    property var activeNetwork: null
    property var networkList: []

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiAvailable: Networking.wifiHardwareEnabled
    readonly property string primaryName: primaryDevice ? primaryDevice.name : ""
    readonly property bool connected: !!primaryDevice && primaryDevice.connected

    readonly property string text: {
        if (!primaryDevice) return "";
        if (primaryDevice.type === DeviceType.Wifi) {
            return primaryDevice.connected && activeNetwork ? "" : "";
        }
        if (primaryDevice.type === DeviceType.Wired) {
            return primaryDevice.connected ? primaryDevice.name + " " : "";
        }
        return primaryDevice.connected ? primaryDevice.name : "";
    }

    readonly property string tooltip: {
        if (!primaryDevice || !primaryDevice.connected) return "Disconnected";
        if (primaryDevice.type === DeviceType.Wifi && activeNetwork) {
            return activeNetwork.name + " (" + Math.round(activeNetwork.signalStrength) + "%) ";
        }
        if (primaryDevice.type === DeviceType.Wired) {
            return primaryName + " ";
        }
        return primaryName;
    }

    function buildNetworkList(device) {
        if (!device || !device.networks) return [];
        var result = device.networks.values.slice();
        result.sort(function (a, b) {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            return b.signalStrength - a.signalStrength;
        });
        return result;
    }

    function refresh() {
        var all = Networking.devices.values;
        var wifi = null;
        var wired = null;
        var best = null;
        var active = null;
        for (var i = 0; i < all.length; i++) {
            var device = all[i];
            if (!device) continue;
            if (device.type === DeviceType.Wifi) wifi = wifi || device;
            if (device.type === DeviceType.Wired) wired = wired || device;
            if (device.connected && (!best || best.type !== DeviceType.Wifi)) best = device;
        }
        if (!best) best = wifi || wired || all[0] || null;
        if (best && best.type === DeviceType.Wifi) {
            var networks = best.networks ? best.networks.values : [];
            for (var j = 0; j < networks.length; j++) {
                if (networks[j].connected) {
                    active = networks[j];
                    break;
                }
            }
        } else if (best && best.type === DeviceType.Wired && best.network && best.network.connected) {
            active = best.network;
        }
        devices = all;
        wifiDevice = wifi;
        wiredDevice = wired;
        primaryDevice = best;
        activeNetwork = active;
        networkList = buildNetworkList(wifi);
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
        UIState.showOsd(Networking.wifiEnabled ? "  on" : "  off");
    }

    function startScan() {
        if (wifiDevice) wifiDevice.scannerEnabled = true;
    }

    function stopScan() {
        if (wifiDevice) wifiDevice.scannerEnabled = false;
    }

    function connect(network, password) {
        if (!network) return;
        if (network.known || !password) network.connect();
        else network.connectWithPsk(password);
    }

    function disconnect() {
        if (!activeNetwork) return;
        activeNetwork.disconnect();
    }

    function sortedNetworks() {
        return networkList;
    }

    Connections {
        target: Networking
        function onWifiEnabledChanged() { root.refresh(); }
    }

    Connections {
        target: Networking.devices
        function onValuesChanged() { root.refresh(); }
    }

    Timer {
        interval: 4000
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
