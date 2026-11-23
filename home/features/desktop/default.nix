# home/features/desktop/default.nix — агрегатор Desktop кубиков
{
  imports = [
    ./compositor/hyprland.nix
    ./compositor/hyprpaper.nix
    ./bar/default.nix
    ./carpheus/default.nix
    ./launcher/rofi.nix
    ./notifications/dunst.nix
    ./udiskie.nix
    ./browsers.nix
    ./firefox/default.nix
    ./apps.nix
    ./orpheus/default.nix
  ];
}
