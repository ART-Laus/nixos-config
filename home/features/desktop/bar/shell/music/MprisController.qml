import QtQuick
import Quickshell.Services.Mpris

QtObject {
  id: root
  property var client: null
  property var player: null
  property string mode: "unavailable"
  property string reason: "No browser MPRIS player"
  property var caps: ({})
  property string preference: "firefox,firefox-esr,librewolf,zen,vivaldi,opera,chromium,google-chrome,chrome,brave-browser,brave,epiphany,webkit"
  signal activePlayerChanged(var player)

  function lower(value) {
    return String(value || "").toLowerCase();
  }

  function isBrowser(p) {
    var id = lower(p.identity) + " " + lower(p.desktopEntry) + " " + lower(p.dbusName);
    var names = root.preference.split(",");
    for (var i = 0; i < names.length; i++) {
      if (names[i].trim() && id.indexOf(names[i].trim()) >= 0) return true;
    }
    return false;
  }

  function metadataUrl(p) {
    var m = p.metadata || {};
    return lower(m["xesam:url"] || m.url || "");
  }

  function isNavidrome(p) {
    var url = root.metadataUrl(p);
    var host = root.client ? lower(root.client.host) : "";
    return (host && url.indexOf(host) >= 0) || url.indexOf("navidrome") >= 0 || url.indexOf("/rest/stream") >= 0;
  }

  function hasTrack(p) {
    return !!(p && String(p.trackTitle || "").trim());
  }

  function score(p) {
    if (!root.isBrowser(p)) return -1;
    if (!p.canControl && !p.isPlaying && !root.hasTrack(p)) return -1;
    if (root.isNavidrome(p)) return 100;
    if (p.isPlaying && root.hasTrack(p)) return 80;
    if (root.hasTrack(p)) return 60;
    return p.canControl ? 20 : -1;
  }

  function refresh() {
    var list = Mpris.players ? Mpris.players.values : [];
    var best = null;
    var bestScore = -1;
    for (var i = 0; i < list.length; i++) {
      var s = root.score(list[i]);
      if (s > bestScore) {
        bestScore = s;
        best = list[i];
      }
    }
    root.player = best;
    root.mode = best ? "browser" : "unavailable";
    root.reason = best
      ? (root.isNavidrome(best) ? "Browser Navidrome playback" : "Browser media player")
      : "No controllable browser MPRIS player found";
    root.caps = best ? {
      canControl: !!best.canControl,
      canPlay: !!best.canPlay,
      canPause: !!best.canPause,
      canTogglePlaying: !!best.canTogglePlaying,
      canGoNext: !!best.canGoNext,
      canGoPrevious: !!best.canGoPrevious,
      canSeek: !!best.canSeek,
      shuffleSupported: !!best.shuffleSupported,
      loopSupported: !!best.loopSupported,
      canOpenUri: !!best.openUri && (best.supportedUriSchemes || []).indexOf("http") >= 0
    } : ({});
    root.activePlayerChanged(best);
  }

  function togglePlaying() {
    if (root.player && root.caps.canTogglePlaying) root.player.togglePlaying();
    else if (root.player && root.caps.canPlay && root.player.playbackState === MprisPlaybackState.Paused) root.player.play();
    else if (root.player && root.caps.canPause && root.player.playbackState === MprisPlaybackState.Playing) root.player.pause();
  }

  function next() {
    if (root.player && root.caps.canGoNext) root.player.next();
  }

  function previous() {
    if (root.player && root.caps.canGoPrevious) root.player.previous();
  }

  function setShuffle(enabled) {
    if (root.player && root.caps.shuffleSupported) root.player.shuffle = enabled;
  }

  function setLoop(state) {
    if (root.player && root.caps.loopSupported) root.player.loopState = state;
  }

  function openUri(uri) {
    if (root.player && root.caps.canOpenUri) root.player.openUri(uri);
  }

  Component.onCompleted: root.refresh()

  property Connections playersConnection: Connections {
    target: Mpris.players
    function onValuesChanged() { root.refresh(); }
  }

  property Connections playerConnection: Connections {
    target: root.player
    function onPlaybackStateChanged() { root.refresh(); }
    function onMetadataChanged() { root.refresh(); }
    function onCanControlChanged() { root.refresh(); }
    function onPositionChanged() { root.refresh(); }
    function onLengthChanged() { root.refresh(); }
    function onTrackArtUrlChanged() { root.refresh(); }
    function onShuffleChanged() { root.refresh(); }
    function onLoopStateChanged() { root.refresh(); }
    function onCanTogglePlayingChanged() { root.refresh(); }
    function onCanGoNextChanged() { root.refresh(); }
    function onCanGoPreviousChanged() { root.refresh(); }
    function onCanSeekChanged() { root.refresh(); }
  }
}
