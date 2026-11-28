# home/features/desktop/compositor/hyprland.nix — Hyprland (Home Manager)
{ theme, pkgs, ... }:
let
  toRgba = hex: "rgba(${builtins.substring 1 2 hex}${builtins.substring 3 2 hex}${builtins.substring 5 2 hex}ff)";
  c = theme.colors;
  hyprexpo = pkgs.callPackage "${pkgs.fetchFromGitHub {
    owner = "sandwichfarm";
    repo = "hyprexpo";
    rev = "v0.55.4";
    hash = "sha256-sERoTu9NcGD0RA3jAdHc4GOPkRbgqMrgDT8f7+Jv9fc=";
  }}/default.nix" { };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = true;

    settings = {
      # Will be generated via extraConfig for now (keep your existing config)
    };

    extraConfig = ''
      plugin = ${hyprexpo}/lib/libhyprexpo.so

      # -----------------------------------------------------
      # Monitors
      # -----------------------------------------------------
      monitor=,preferred,auto,1

      # -----------------------------------------------------
      # Autostart
      # -----------------------------------------------------
      exec-once = nm-applet --indicator

      # -----------------------------------------------------
      # Environment
      # -----------------------------------------------------
      env = XCURSOR_SIZE,24
      env = QT_QPA_PLATFORMTHEME,qt6ct

      # -----------------------------------------------------
      # Look & Feel — из theme/colors.nix
      # -----------------------------------------------------
      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = ${toRgba theme.colors.primary}
          col.inactive_border = ${toRgba theme.colors.muted}
          layout = dwindle
      }

      decoration {
          rounding = 8
          active_opacity = 0.9
          inactive_opacity = 0.8
          blur {
              enabled = true
              size = 5
              passes = 3
              new_optimizations = true
              xray = true
          }
          shadow {
              enabled = yes
              range = 10
              render_power = 3
              color = ${c.shadow}
          }
      }

      animations {
          enabled = yes
          bezier = myBezier, 0.10, 0.9, 0.1, 1.05
          animation = windows, 1, 7, myBezier, slide
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      input {
          kb_layout = us,ru
          kb_options =
          follow_mouse = 1
          touchpad {
              natural_scroll = no
          }
      }

      misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
      }

      # Thunar: CSS отвечает за поверхность, без дополнительного opacity от Hyprland
      windowrule = opacity 1 1, match:class ^(thunar|Thunar)$
      # Firefox - прозрачность как в системе (active 0.9 / inactive 0.8)
      windowrule = opacity 0.9 0.8, match:class ^(firefox)$

      $mainMod = SUPER

      plugin {
          hyprexpo {
              columns = 3
              gaps_in = 5
              gaps_out = 0
              bg_col = rgb(111111)
              workspace_method = center current
              gesture_distance = 200
              cancel_key = escape
          }
      }
      bind = $mainMod ALT, Shift_L, hyprexpo:expo, toggle
      bind = SHIFT, Tab, exec, hyprctl switchxkblayout current next
      bind = $mainMod, Space, exec, quickshell ipc -c bar call appCenter toggle
      bind = $mainMod, Return, exec, alacritty
      bind = $mainMod, code:56, exec, firefox
      bind = $mainMod, code:28, exec, AyuGram
      bind = $mainMod, code:26, exec, thunar
      bind = $mainMod, W, exec, wallpaper
      bind = $mainMod, code:32, exec, obsidian
      bind = $mainMod, code:40, exec, show-desktop
      bind = $mainMod, code:24, killactive,
      bind = $mainMod, code:54, killactive,
      bind = $mainMod, code:58, exit,
      bind = $mainMod, code:41, togglefloating,
      bind = $mainMod SHIFT, code:41, fullscreen,
      bind = $mainMod, minus, movetoworkspacesilent, special:minimized
      bind = $mainMod, equal, togglespecialworkspace, minimized
      bind = $mainMod, code:27, exec, rofi-scripts
      bind = $mainMod, V, exec, quickshell ipc -c bar call clipboard toggle
      bind = $mainMod, code:57, exec, io.github.alainm23.planify
      bind = $mainMod, code:53, exec, qalculate-gtk
      bind = $mainMod, code:29, exec, alacritty -e yazi
      bind = , Print, exec, screenshot-save gui
      bind = SHIFT, Print, exec, screenshot-save full
      bind = $mainMod, code:43, movefocus, l
      bind = $mainMod, code:44, movefocus, d
      bind = $mainMod, code:45, movefocus, u
      bind = $mainMod, code:46, movefocus, r
      bind = $mainMod SHIFT, code:43, movewindow, l
      bind = $mainMod SHIFT, code:44, movewindow, d
      bind = $mainMod SHIFT, code:45, movewindow, u
      bind = $mainMod SHIFT, code:46, movewindow, r
      binde = $mainMod, left, resizeactive, -5 0
      binde = $mainMod, right, resizeactive, 5 0
      binde = $mainMod, up, resizeactive, 0 -5
      binde = $mainMod, down, resizeactive, 0 5
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '';
  };
}
