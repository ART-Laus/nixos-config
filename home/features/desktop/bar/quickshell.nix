{ config, lib, pkgs, theme, ... }:
let
  c = theme.colors;

  appCenterPython = pkgs.python3.withPackages (p: [ p.psutil ]);
  appCenterBackend = pkgs.writeShellScriptBin "appcenter-process-monitor" ''
    exec ${appCenterPython.interpreter} ${./../app-center/backend/process_monitor.py} "$@"
  '';
  appCenterUsagePath = "${config.xdg.dataHome}/quickshell/app-center/usage.json";

  scriptHubCommands = [
    "rofi-scripts"
    "wallpaper"
    "show-desktop"
    "rofi-image"
    "rofi-video"
    "rofi-audio"
    "extract"
    "archive"
    "fileinfo"
    "hashfile"
    "share"
    "doctor"
    "nixcheck"
    "make-qr"
    "clip-ocr"
    "tidy-downloads"
    "img-resize"
    "img-compress"
    "vid2audio"
    "vid2gif"
    "pdf2text"
    "batch-rename"
    "find-duplicates"
    "new-note"
    "docker"
    "docker-compose"
    "carpheus-api"
    "carpheus-mpv-ipc"
  ];

  scriptHubDiscover = pkgs.writeShellApplication {
    name = "script-hub-discover";
    runtimeInputs = [ pkgs.python3 ];
    text = ''
      exec ${pkgs.python3.interpreter} ${./scripts/script-hub-discover.py} "$@"
    '';
  };

  scriptHubConfig = pkgs.writeText "script-hub-config.json" (builtins.toJSON {
    roots = [
      {
        path = "${./../../../../scripts}";
        label = "Config scripts";
        recursive = true;
        maxDepth = 1;
      }
      {
        path = "${./scripts}";
        label = "Bar scripts";
        recursive = false;
        maxDepth = 0;
      }
      {
        path = "${./../carpheus/scripts}";
        label = "Carpheus scripts";
        recursive = false;
        maxDepth = 0;
      }
      {
        path = "${config.xdg.dataHome}/../bin";
        label = "Local bin";
        recursive = true;
        maxDepth = 1;
      }
      {
        path = "${config.xdg.dataHome}";
        label = "Local share";
        recursive = false;
        maxDepth = 0;
      }
      {
        path = "${config.xdg.configHome}";
        label = "Local config";
        recursive = false;
        maxDepth = 0;
      }
    ];
    commands = map (name: { command = name; label = "Nix commands"; }) scriptHubCommands;
    excluded = [ "/proc" "/sys" "/dev" ];
  });

  scriptHubDataRoot = "${config.xdg.dataHome}/quickshell/script-hub";

  themeQml = pkgs.writeText "Theme.qml" ''
    pragma Singleton
    import QtQuick

    QtObject {
        readonly property color primary: "${c.primary}"
        readonly property color primaryDim: "${c.primaryDim}"
        readonly property color secondary: "${c.secondary}"
        readonly property color error: "${c.error}"
        readonly property color warning: "${c.warning}"
        readonly property color info: "${c.info}"

        readonly property color section: "${c.barSection}"

        readonly property color pillBase: "${c.barPill}"
        readonly property color pill: Qt.rgba(pillBase.r, pillBase.g, pillBase.b, ${toString c.barPillOpacity})
        readonly property color pillHover: Qt.rgba(pillBase.r, pillBase.g, pillBase.b, ${toString c.barPillHoverOpacity})
        readonly property color pillActive: Qt.rgba(primary.r, primary.g, primary.b, ${toString c.barPillActiveOpacity})
        readonly property color tooltip: Qt.rgba(pillBase.r, pillBase.g, pillBase.b, ${toString c.barTooltipOpacity})

        readonly property color text: "${c.primary}"
        readonly property color textDim: Qt.rgba(primary.r, primary.g, primary.b, 0.9)

        readonly property string fontFamily: "${theme.fonts.ui.name}"
        readonly property int fontSize: ${toString (theme.fonts.ui.size + 1)}

        readonly property string processBackend: "${appCenterBackend}/bin/appcenter-process-monitor"
        readonly property string usagePath: "${appCenterUsagePath}"

        readonly property string scriptHubDiscover: "${scriptHubDiscover}/bin/script-hub-discover"
        readonly property string scriptHubConfigPath: "${scriptHubConfig}"
        readonly property string scriptHubLocalConfigPath: "${config.xdg.configHome}/quickshell/script-hub/config.local.json"
        readonly property string scriptHubDataRoot: "${scriptHubDataRoot}"
        readonly property string scriptHubMetadataPath: scriptHubDataRoot + "/metadata.json"
        readonly property string scriptHubStatePath: scriptHubDataRoot + "/state.json"
        readonly property string scriptHubHistoryPath: scriptHubDataRoot + "/history.json"
        readonly property string scriptHubMkdir: "${pkgs.coreutils}/bin/mkdir"
        readonly property string scriptHubCp: "${pkgs.coreutils}/bin/cp"
    }
  '';

  shellConfig = pkgs.runCommand "quickshell-bar-config" { } ''
    mkdir -p $out $out/appcenter
    cp -r ${./shell}/. $out/
    cp -r ${./../app-center/shell}/. $out/appcenter/
    chmod -R u+w $out
    cp ${themeQml} $out/config/Theme.qml
    cp ${./../app-center/shell/config}/AppSettings.qml $out/config/AppSettings.qml
    cp ${./../app-center/shell/config}/AppState.qml $out/config/AppState.qml
  '';
in
lib.mkIf config.artlaus.desktop.bar.enable {
  programs.quickshell = {
    enable = true;
    package = pkgs.quickshell;
    configs.bar = shellConfig;
    activeConfig = "bar";
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
  };

  home.packages = with pkgs; [
    brightnessctl
    bluez
    blueman
    networkmanager
    networkmanagerapplet
    hyprland
    scriptHubDiscover
  ];

  home.activation.scriptHubData = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${scriptHubDataRoot}" "${config.xdg.configHome}/quickshell/script-hub"
    [ -f "${scriptHubDataRoot}/metadata.json" ] || printf '%s\n' '{}' > "${scriptHubDataRoot}/metadata.json"
    [ -f "${scriptHubDataRoot}/state.json" ] || printf '%s\n' '{"favorites":[],"recent":[],"usage":{}}' > "${scriptHubDataRoot}/state.json"
    [ -f "${scriptHubDataRoot}/history.json" ] || printf '%s\n' '[]' > "${scriptHubDataRoot}/history.json"
    [ -f "${config.xdg.configHome}/quickshell/script-hub/config.local.json" ] || printf '%s\n' '{}' > "${config.xdg.configHome}/quickshell/script-hub/config.local.json"
  '';
}
