{ config, lib, pkgs, theme, ... }:
let
  c = theme.colors;
  v = theme.colors.verdant;

  # hex → "r, g, b" в диапазоне 0..1 для Qt.rgba() в QML.
  # builtins в этой версии Nix нет fromHex/stringToCharacters — считаем вручную.
  rgbFloats = hex:
    let
      charIndex = needle: haystack:
        let
          len = builtins.stringLength haystack;
          go = i:
            if i >= len then null
            else if builtins.substring i 1 haystack == needle then i
            else go (i + 1);
        in go 0;
      parts = builtins.split "" (builtins.substring 1 6 hex);
      digitVal = c:
        let i = charIndex c "0123456789abcdefABCDEF";
        in if i == null then 0 else if i < 10 then i else i - 6;
      byte = i: digitVal (builtins.elemAt parts (4 * i + 2)) * 16
        + digitVal (builtins.elemAt parts (4 * i + 4));
    in "${toString (byte 0 / 255.0)}, ${toString (byte 1 / 255.0)}, ${toString (byte 2 / 255.0)}";

  appCenterPython = pkgs.python3.withPackages (p: [ p.psutil ]);
  appCenterBackend = pkgs.writeShellScriptBin "appcenter-process-monitor" ''
    exec ${appCenterPython.interpreter} ${./../app-center/backend/process_monitor.py} "$@"
  '';
  appCenterUsagePath = "${config.xdg.dataHome}/quickshell/app-center/usage.json";

  # Verdant Clipboard lives inside this Quickshell config — no second instance.
  clipboardShell = import ./../clipboard/frontend.nix { inherit pkgs; };
  clipboardCtl = "${import ./../clipboard/backend.nix { inherit pkgs; }}/bin/verdant-clipboard-ctl";

  scriptHubCommands = [
    "rofi-scripts"
    "wallpaper"
    "show-desktop"
    "rofi-image"
    "rofi-video"
    "rofi-audio"
    "camera-mirror"
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
  notificationDataRoot = "${config.xdg.dataHome}/quickshell/notifications";

  themeQml = pkgs.writeText "Theme.qml" ''
    pragma Singleton
    import QtQuick

    QtObject {
        // Verdant / Living Terminal — общие токены для бара и App Center.
        readonly property color primary: "${v.mint}"
        readonly property color primaryDim: "${v.emerald}"
        readonly property color secondary: "${v.lavender}"
        readonly property color error: "${v.danger}"
        readonly property color warning: "${v.warning}"
        readonly property color info: "${v.sage}"
        readonly property color inverse: "${v.deep}"

        readonly property color section: "${v.elevated}"

        readonly property color pillBase: "${v.elevated}"
        readonly property color pill: Qt.rgba(pillBase.r, pillBase.g, pillBase.b, 0.88)
        readonly property color pillHover: Qt.rgba(${rgbFloats v.hover}, 0.94)
        readonly property color pillActive: Qt.rgba(primary.r, primary.g, primary.b, 0.2)
        readonly property color tooltip: Qt.rgba(pillBase.r, pillBase.g, pillBase.b, 1)

        // Слоистые поверхности App Center (вместо чёрного #000000).
        readonly property color panel: Qt.rgba(${rgbFloats v.main}, 0.94)
        readonly property color panelAlt: Qt.rgba(${rgbFloats v.elevated}, 0.94)
        readonly property color border: Qt.rgba(${rgbFloats v.border}, 0.85)

        readonly property color text: "${v.text}"
        readonly property color textDim: "${v.text2}"
        readonly property color muted: "${v.muted}"

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

        readonly property string notificationDataRoot: "${notificationDataRoot}"
        readonly property string notificationHistoryPath: notificationDataRoot + "/history.json"
        readonly property string notificationStatePath: notificationDataRoot + "/state.json"
        readonly property string notificationRulesPath: notificationDataRoot + "/rules.json"
        readonly property string notificationMkdir: "${pkgs.coreutils}/bin/mkdir"

        readonly property string clipboardCtl: "${clipboardCtl}"
        readonly property string clipboardDataRoot: "${config.xdg.dataHome}/verdant-clipboard"
    }
  '';

  shellConfig = pkgs.runCommand "quickshell-bar-config" { } ''
    mkdir -p $out $out/appcenter
    cp -r ${./shell}/. $out/
    cp -r ${./../app-center/shell}/. $out/appcenter/
    cp -r ${clipboardShell}/. $out/clipboard/
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

  home.activation.notificationData = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${notificationDataRoot}"
    [ -f "${notificationDataRoot}/history.json" ] || printf '%s\n' '{"version":1,"entries":[]}' > "${notificationDataRoot}/history.json"
    [ -f "${notificationDataRoot}/state.json" ] || printf '%s\n' '{"version":1,"expandedGroups":{},"view":{"category":"all","status":"inbox"}}' > "${notificationDataRoot}/state.json"
    [ -f "${notificationDataRoot}/rules.json" ] || printf '%s\n' '{"version":1,"overrides":{}}' > "${notificationDataRoot}/rules.json"
  '';

  # QML is loaded once at startup, so a switch leaves the running bar on old code.
  home.activation.restartQuickshell = lib.hm.dag.entryAfter [ "linkGeneration" "installPackages" ] ''
    ${pkgs.systemd}/bin/systemctl --user try-restart quickshell.service || true
  '';
}
