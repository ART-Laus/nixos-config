{ config, pkgs, ... }:

let
  # Define the color palette
  colors = {
    foreground = "#C0FFC0";
    background = "#001a0d";
    cursor_bg = "#66FF99";
    cursor_border = "#66FF99";
    cursor_fg = "#0A0A0F";
    selection_bg = "#66FF99";
    selection_fg = "#0A0A0F";
    ansi = [
      "#1E1E2E" "#FF007C" "#00FF9F" "#FFD500"
      "#00BFFF" "#B400FF" "#00FFFF" "#C0C0C0"
    ];
    brights = [
      "#2E2E3E" "#FF3399" "#33FFB2" "#FFE066"
      "#33CFFF" "#CC66FF" "#66FFFF" "#FFFFFF"
    ];
    tab_bar = {
      background = "#000000";
      active_tab = {
        bg_color = "#66FF99";
        fg_color = "#001a0d";
        intensity = "Bold";
      };
      inactive_tab = {
        bg_color = "#000000";
        fg_color = "#448866";
      };
      inactive_tab_hover = {
        bg_color = "#003322";
        fg_color = "#66FF99";
      };
      new_tab = {
        bg_color = "#000000";
        fg_color = "#66FF99";
      };
      new_tab_hover = {
        bg_color = "#001a0d";
        fg_color = "#66FF99";
      };
    };
  };

  # Define keybindings
  keybindings = [
    # New window
    { mods = "LEADER"; key = "n"; action = { SpawnTab = "CurrentPaneDomain"; }; }
    # Close window
    { mods = "LEADER"; key = "q"; action = { CloseCurrentPane = { confirm = true; }; }; }
    # Previous window
    { mods = "LEADER"; key = "b"; action = { ActivateTabRelative = -1; }; }
    # Next window
    { mods = "LEADER"; key = "f"; action = { ActivateTabRelative = 1; }; }
    # Split panes
    { mods = "LEADER"; key = "v"; action = { SplitHorizontal = { domain = "CurrentPaneDomain"; }; }; }
    { mods = "LEADER"; key = "h"; action = { SplitVertical = { domain = "CurrentPaneDomain"; }; }; }
    # Move between panes
    { mods = "LEADER"; key = "k"; action = { ActivatePaneDirection = "Down"; }; }
    { mods = "LEADER"; key = "j"; action = { ActivatePaneDirection = "Up"; }; }
    { mods = "LEADER"; key = ";"; action = { ActivatePaneDirection = "Right"; }; }
    { mods = "LEADER"; key = "l"; action = { ActivatePaneDirection = "Left"; }; }
    # Resize panes
    { mods = "LEADER"; key = "LeftArrow"; action = { AdjustPaneSize = [ "Left" 5 ]; }; }
    { mods = "LEADER"; key = "RightArrow"; action = { AdjustPaneSize = [ "Right" 5 ]; }; }
    { mods = "LEADER"; key = "DownArrow"; action = { AdjustPaneSize = [ "Down" 5 ]; }; }
    { mods = "LEADER"; key = "UpArrow"; action = { AdjustPaneSize = [ "Up" 5 ]; }; }
    # Copy/Paste
    { mods = "CTRL"; key = "c"; action = { CopyTo = "Clipboard"; }; }
    { mods = "CTRL"; key = "v"; action = { PasteFrom = "Clipboard"; }; }
    # Fullscreen
    { mods = "NONE"; key = "F11"; action = "ToggleFullScreen"; }
  ] ++ (
    # Loop for tab switching (0-9)
    pkgs.lib.genAttrs (pkgs.lib.range 0 9) (i: {
      mods = "LEADER";
      key = toString i;
      action = { ActivateTab = i; };
    })
  );

in {
  programs.wezterm = {
    enable = true;

    # Main window settings
    font = "JetBrains Mono";
    fontSize = 14.0;
    cellWidth = 0.95;
    windowBackgroundOpacity = 0.85;
    textBackgroundOpacity = 1.0;
    windowDecorations = "RESIZE";
    windowCloseConfirmation = "NeverPrompt";
    windowPadding = { left = 0; right = 0; top = 0; bottom = 0; };
    defaultCursorStyle = "BlinkingUnderline";
    cursorBlinkRate = 900;
    enableScrollBar = false;
    scrollbackLines = 5000;
    enableCsiUKeyEncoding = false;
    defaultProg = [ "wsl.exe" ]; # This might need adjustment for NixOS

    # Leader key
    leader = { key = "`"; mods = "CTRL"; timeoutMilliseconds = 5000; };

    # Keybindings
    keys = keybindings;

    # Tab bar settings
    hideTabBarIfOnlyOneTab = false;
    tabBarAtBottom = true;
    useFancyTabBar = false;
    tabAndSplitIndicesAreZeroBased = true;

    # Performance settings
    maxFps = 240;
    animationFps = 240;

    # Colors
    inherit colors;

    # Event handler for leader indicator (requires extraConfig)
    extraConfig = ''
      wezterm.on("update-status", function(window, _)
        if window:leader_is_active() then
          window:set_left_status(wezterm.format {
            { Background = { Color = "#66FF99" } },
            { Foreground = { Color = "#001a0d" } },
            { Text = " 🦉" },
          })
        else
          window:set_left_status("")
        end
      end)
    '';
  };

  home.sessionVariables.TERMINAL = "wezterm";
}
