# home/features/desktop/default.nix — агрегатор Desktop кубиков
{
  imports = [
    ./compositor/hyprland.nix
    ./compositor/hyprpaper.nix
    ./bar/default.nix
    ./carpheus/default.nix
    ./launcher/rofi.nix
    # Quickshell owns org.freedesktop.Notifications; dunst must not run too.
    ./udiskie.nix
    ./browsers.nix
    ./firefox/default.nix
    ./apps.nix
    ./file-manager
    ./orpheus/default.nix
  ];
}
