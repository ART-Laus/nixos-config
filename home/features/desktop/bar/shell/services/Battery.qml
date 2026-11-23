pragma Singleton
import QtQuick
import Quickshell.Services.UPower

Item {
    readonly property var device: UPower.displayDevice
    readonly property bool present: !!device && device.isPresent
    readonly property int capacity: present ? Math.max(0, Math.min(100, Math.round(device.percentage))) : 0
    readonly property bool charging: present && (
        device.state === UPowerDeviceState.Charging ||
        device.state === UPowerDeviceState.PendingCharge ||
        device.state === UPowerDeviceState.FullyCharged
    )
    readonly property bool critical: present && !charging && capacity <= 15

    readonly property string icon: {
        if (capacity >= 95) return "";
        if (capacity >= 75) return "";
        if (capacity >= 50) return "";
        if (capacity >= 25) return "";
        return "";
    }

    readonly property string text: "1" + capacity + "% " + icon

    readonly property string tooltip: {
        if (!present) return "No battery";
        if (charging) return "Charging " + capacity + "%";
        return "Battery " + capacity + "%";
    }
}
