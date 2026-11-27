# Home Manager module for the persistent Orpheus coordinator.
# Disabled by default: enable explicitly with `orpheus.daemon.enable = true`.
{ config, pkgs, lib, ... }:
let
  daemonPkg = import ./daemon/package.nix { inherit pkgs lib; };
in
{
  options.orpheus.daemon.enable = lib.mkEnableOption
    "persistent headless Orpheus coordinator with mpv and Navidrome";

  config = lib.mkIf config.orpheus.daemon.enable {
    home.packages = [ daemonPkg ];

    home.activation.orpheusDaemonDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      runtime="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      state="''${XDG_STATE_HOME:-$HOME/.local/state}"
      install -d -m 700 "$runtime/orpheus" 2>/dev/null || true
      install -d -m 700 "$state/orpheus" 2>/dev/null || true
    '';

    systemd.user.services.orpheus-daemon = {
      Unit = {
        Description = "Orpheus music coordinator (mpv + Navidrome session)";
        After = [ "orpheus-navidrome.service" "hyprland-session.target" ];
        Wants = [ "orpheus-navidrome.service" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${daemonPkg}/bin/orpheus-daemon";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
