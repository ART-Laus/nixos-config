# artlaus/features/desktop/hypr/hyprland.nix
# Configuration for the Hyprland window manager with niri-like layout.
{ pkgs, ... }:

# Helper function to convert hex to rgba for Hyprland
let
  toRgba = hex: "rgba(${builtins.substring 1 2 hex}${builtins.substring 3 2 hex}${builtins.substring 5 2 hex}ff)";
in
{
  # Enable and configure Hyprland through home-manager
  home-manager.users.artlaus = { ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      # Use the Hyprland package from the flake input for compatibility with the plugin
      package = (pkgs.hyprland.override {
        # This allows the plugin to be loaded
        hyprland-plugins = [ inputs.hypr-niri ];
      });

      # Main configuration
      extraConfig = ''
        # -----------------------------------------------------
        # Monitors
        # -----------------------------------------------------
        monitor=,preferred,auto,1

        # -----------------------------------------------------
        # Autostart Essential Daemons
        # -----------------------------------------------------
        exec-once = waybar &
        exec-once = nm-applet --indicator
        exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &
        exec-once = /nix/store/$(nix-instantiate --eval -A polkit_gnome.outPath '<nixpkgs>')/libexec/polkit-gnome-authentication-agent-1 &
        exec-once = dunst & # Notification daemon
        exec-once = hyprpaper & # Wallpaper daemon
        exec-once = wl-paste --watch cliphist store # Clipboard history

        # -----------------------------------------------------
        # Wallpaper Configuration (hyprpaper)
        # -----------------------------------------------------
        # Set a solid dark green wallpaper to match the theme
        exec-once = hyprctl hyprpaper wallpaper ",#001a0d"

        # -----------------------------------------------------
        # Environment
        # -----------------------------------------------------
        env = XCURSOR_SIZE,24
        env = QT_QPA_PLATFORMTHEME,qt5ct

        # -----------------------------------------------------
        # Layout & Plugin Config
        # -----------------------------------------------------
        # Set niri as the default layout
        layout = niri

        # Configure the niri layout plugin
        plugin {
          niri-layout {
            # Put new windows to the right of the active one
            new_on_right = true
          }
        }

        # -----------------------------------------------------
        # Look & Feel (Aesthetics from wezterm config)
        # -----------------------------------------------------
        general {
            gaps_in = 5
            gaps_out = 10
            border_size = 2
            # Green accent for active window, darker green for inactive
            col.active_border = ${toRgba "#66FF99"}
            col.inactive_border = ${toRgba "#448866"}

            layout = niri
        }

        decoration {
            rounding = 8
            
            # Opacity for active and inactive windows
            active_opacity = 0.95
            inactive_opacity = 0.85

            # Background blur
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

        # -----------------------------------------------------
        # Input
        # -----------------------------------------------------
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
            # Disable the initial welcome message/wallpaper
            disable_hyprland_logo = true
            disable_splash_rendering = true
        }

        # -----------------------------------------------------
        # Keybinds (Inspired by wezterm config)
        # -----------------------------------------------------
        $mainMod = SUPER

        # Apps
        bind = $mainMod, Q, exec, alacritty
        bind = $mainMod, E, exec, thunar
        bind = $mainMod, Space, exec, rofi -show drun

        # Window management
        bind = $mainMod, C, killactive,
        bind = $mainMod, M, exit,
        bind = $mainMod, F, togglefloating,

        # Custom scripts menu
        bind = $mainMod, R, exec, rofi-scripts

        # --- Full Desktop Environment Keybinds ---
        
        # Screen Locking
        bind = $mainMod, L, exec, swaylock
        
        # Screenshots
        bind = , Print, exec, grim -g "$(slurp)" - | swappy -f - # Select region and edit
        bind = SHIFT, Print, exec, grim - | swappy -f - # Screenshot whole screen and edit

        # Clipboard History
        bind = $mainMod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

        # Move focus (niri-style)
        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r

        # Move window (niri-style)
        bind = $mainMod SHIFT, left, movewindow, l
        bind = $mainMod SHIFT, right, movewindow, r

        # Switch workspaces
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

        # Move active window to a workspace
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

        # Scroll through workspaces
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up, workspace, e-1

        # Move/resize windows with mouse
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow
      '';
    };
  };
}
