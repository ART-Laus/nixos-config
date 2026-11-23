pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.config

Item {
    id: root

    property var sinks: []
    property var sources: []
    property var streams: []

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property int sinkVolume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property int sourceVolume: source && source.audio ? Math.round(source.audio.volume * 100) : 0
    readonly property bool sinkMuted: !sink || !sink.audio || sink.audio.muted
    readonly property bool sourceMuted: !source || !source.audio || source.audio.muted

    readonly property string sinkIcon: {
        if (sinkMuted) return isBluetoothSink(sink) ? "" : "";
        if (isBluetoothSink(sink)) return "";
        var label = sink ? (String(sink.name) + " " + String(sink.description)) : "";
        if (/headphone/i.test(label)) return "";
        if (/headset|hands.?free/i.test(label)) return "";
        if (/phone|portable/i.test(label)) return "";
        if (/car/i.test(label)) return "";
        return sinkVolume >= 70 ? "" : sinkVolume >= 30 ? "" : "";
    }
    readonly property string sinkText: sink ? sinkIcon : ""
    readonly property string sourceText: sourceMuted ? "" : ""
    readonly property string sinkTooltip: sink ? (sink.description || sink.name) + "  " + sinkVolume + "%" : "No audio output"
    readonly property string sourceTooltip: source ? (source.description || source.name) + "  " + sourceVolume + "%" : "No audio input"

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    function clamp(value, min, max) {
        return Math.max(min, Math.min(max, value));
    }

    function isBluetoothSink(node) {
        if (!node) return false;
        var text = String(node.name || "") + " " + String(node.description || "");
        return /bluez|bluetooth/i.test(text);
    }

    function refresh() {
        var sinkList = [];
        var sourceList = [];
        var streamList = [];
        var nodes = Pipewire.nodes.values;
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            if (!node || !node.audio) continue;
            if (node.isStream) {
                streamList.push(node);
            } else if (node.isSink) {
                sinkList.push(node);
            } else {
                sourceList.push(node);
            }
        }
        sinks = sinkList;
        sources = sourceList;
        streams = streamList;
    }

    function setSinkVolume(value) {
        if (!sink || !sink.audio) return;
        var next = clamp(value, 0, 150) / 100;
        sink.audio.volume = next;
        UIState.showOsd("  " + Math.round(next * 100) + "%");
    }

    function setSourceVolume(value) {
        if (!source || !source.audio) return;
        source.audio.volume = clamp(value, 0, 150) / 100;
    }

    function setNodeVolume(node, value) {
        if (!node || !node.audio) return;
        node.audio.volume = clamp(value, 0, 150) / 100;
    }

    function stepSink(delta) {
        if (!sink || !sink.audio) return;
        setSinkVolume(sinkVolume + delta);
    }

    function toggleSinkMute() {
        if (!sink || !sink.audio) return;
        sink.audio.muted = !sink.audio.muted;
        UIState.showOsd(sink.audio.muted ? "  mute" : "  unmute");
    }

    function toggleSourceMute() {
        if (!source || !source.audio) return;
        source.audio.muted = !source.audio.muted;
    }

    function toggleNodeMute(node) {
        if (!node || !node.audio) return;
        node.audio.muted = !node.audio.muted;
    }

    function selectSink(node) {
        if (!node) return;
        Pipewire.preferredDefaultAudioSink = node;
    }

    function selectSource(node) {
        if (!node) return;
        Pipewire.preferredDefaultAudioSource = node;
    }

    Connections {
        target: Pipewire
        function onReadyChanged() { root.refresh(); }
        function onDefaultAudioSinkChanged() { root.refresh(); }
        function onDefaultAudioSourceChanged() { root.refresh(); }
    }

    Connections {
        target: Pipewire.nodes
        function onValuesChanged() { root.refresh(); }
    }

    Component.onCompleted: root.refresh()
}
