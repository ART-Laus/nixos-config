# home/features/desktop/default.nix — агрегатор Desktop кубиков
{
  imports = [
    ./compositor/hyprland.nix
    ./compositor/hyprpaper.nix
    ./bar/waybar.nix
    ./launcher/rofi.nix
    ./notifications/dunst.nix
    ./lockscreen/swaylock.nix
    ./lockscreen/swayidle.nix
    ./browsers.nix
    ./apps.nix
  ];
}
