# Verdant Clipboard — Home Manager module.
#
# Split by responsibility:
#   backend.nix   — stdlib Python daemon + ctl client package
#   frontend.nix  — QML sources, copied into the existing `bar` Quickshell config
#   default.nix   — options, config file, systemd user service
#   backend/      — daemon implementation
#   shell/        — Quickshell UI implementation
{ config, lib, pkgs, ... }:
let
  cfg = config.artlaus.desktop.clipboard;
  backend = import ./backend.nix { inherit pkgs; };

  clipboardConfig = builtins.toJSON {
    maxEntries = cfg.maxEntries;
    maxTextBytes = cfg.maxTextBytes;
    maxImageBytes = cfg.maxImageBytes;
    maxOtherBytes = cfg.maxOtherBytes;
    previewChars = 500;
    thumbnailPx = 320;
    captureImages = cfg.captureImages;
    persistRestore = cfg.persistRestore;
    ignoreApps = cfg.ignoreApps;
    ignorePatterns = cfg.ignorePatterns;
  };
  configFile = "${config.xdg.configHome}/verdant-clipboard/config.json";
in
{
  options.artlaus.desktop.clipboard = {
    enable = lib.mkEnableOption "Verdant Clipboard (persistent Wayland clipboard manager)" // {
      default = true;
    };
    maxEntries = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "Maximum number of unpinned history entries.";
    };
    maxTextBytes = lib.mkOption {
      type = lib.types.int;
      default = 1024 * 1024;
      description = "Largest text selection persisted, in bytes.";
    };
    maxImageBytes = lib.mkOption {
      type = lib.types.int;
      default = 25 * 1024 * 1024;
      description = "Largest image selection persisted, in bytes.";
    };
    maxOtherBytes = lib.mkOption {
      type = lib.types.int;
      default = 8 * 1024 * 1024;
      description = "Largest binary (non-image) selection persisted, in bytes.";
    };
    captureImages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run a second wl-paste watcher for image/* selections.";
    };
    persistRestore = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Keep restored content owned by wl-copy so closing the source app does not clear it.";
    };
    persistSelection = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Also run wl-clip-persist for selections made by other applications.";
    };
    ignoreApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Window classes whose clipboard contents must never be stored.";
    };
    ignorePatterns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Regular expressions; matching text selections are not stored.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ backend ] ++ lib.optional cfg.persistSelection pkgs.wl-clip-persist;

    home.activation.verdantClipboardConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      install -d -m 700 "${config.xdg.configHome}/verdant-clipboard"
      install -d -m 700 "${config.xdg.dataHome}/verdant-clipboard"
      printf '%s\n' '${clipboardConfig}' > "${configFile}"
      chmod 600 "${configFile}" 2>/dev/null || true
    '';

    systemd.user.services.verdant-clipboard = {
      Unit = {
        Description = "Verdant Clipboard — persistent Wayland clipboard history";
        PartOf = [ "hyprland-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${backend}/bin/verdant-clipboard";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };

    systemd.user.services.verdant-clipboard-persist = lib.mkIf cfg.persistSelection {
      Unit = {
        Description = "Keep Wayland clipboard contents after the source application exits";
        PartOf = [ "hyprland-session.target" ];
        After = [ "verdant-clipboard.service" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };
  };
}
