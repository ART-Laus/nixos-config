# artlaus/features/desktop/default.nix
# This module contains packages and settings for the graphical desktop environment.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # --- Core Desktop/GUI Utilities ---
    rofi
    libnotify      # For sending desktop notifications
    playerctl      # For controlling media players via keybindings
    xdg-utils      # For xdg-open to launch files with default apps
    
    # --- Wayland Specific Tools ---
    wl-clipboard   # Clipboard utilities for Wayland
    grim           # Screenshot utility for Wayland
    slurp          # For selecting a region for grim
    swappy         # For editing screenshots
    hyprpaper      # Wallpaper daemon for Hyprland
    hyprpicker     # Color picker for Hyprland
    
    # --- Essential Desktop Daemons (added for a full experience) ---
    dunst          # Notification daemon
    swaylock       # Screen locker
    cliphist       # Clipboard history manager

    # --- Other GUI tools that were in the CLI module ---
    xclip          # X11 clipboard utility (good to have for compatibility)
    xcolor         # X11 color picker
  ];
}
