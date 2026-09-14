# home/features/desktop/compositor/hyprland.nix — Hyprland (Home Manager)
{ config, pkgs, lib, theme, inputs, ... }:
let
  toRgba = hex: "rgba(${builtins.substring 1 2 hex}${builtins.substring 3 2 hex}${builtins.substring 5 2 hex}ff)";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # package = pkgs.hyprland; # use nixpkgs hyprland (pin via flake if needed)

    settings = {
      # Will be generated via extraConfig for now (keep your existing config)
    };

    extraConfig = ''
      # -----------------------------------------------------
      # Monitors
      # -----------------------------------------------------
      monitor=,preferred,auto,1

      # -----------------------------------------------------
      # Autostart
      # -----------------------------------------------------
      exec-once = waybar &
      exec-once = nm-applet --indicator
      exec-once = wl-paste --watch cliphist store

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
          active_opacity = 0.95
          inactive_opacity = 0.85
          blur {
              enabled = true
              size = 4
              passes = 2
              new_optimizations = true
              xray = true
          }
          drop_shadow = yes
          shadow_range = 10
          shadow_render_power = 3
          col.shadow = rgba(00000066)
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
          kb_options = grp:alt_shift_toggle
          follow_mouse = 1
          touchpad {
              natural_scroll = no
          }
      }

      gestures {
          workspace_swipe = on
      }

      misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
      }

      $mainMod = SUPER
      bind = $mainMod, Q, exec, wezterm
      bind = $mainMod, E, exec, thunar
      bind = $mainMod, Space, exec, rofi -show drun
      bind = $mainMod, C, killactive,
      bind = $mainMod, M, exit,
      bind = $mainMod, F, togglefloating,
      bind = $mainMod, R, exec, rofi-scripts
      bind = $mainMod, L, exec, swaylock
      bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -
      bind = SHIFT, Print, exec, grim - | swappy -f -
      bind = $mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod SHIFT, left, movewindow, l
      bind = $mainMod SHIFT, right, movewindow, r
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
