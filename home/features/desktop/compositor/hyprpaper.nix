# home/features/desktop/compositor/hyprpaper.nix — обои
{ config, pkgs, lib, theme, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "${theme.colors.bg}" ];
      wallpaper = [ ",${theme.colors.bg}" ];
    };
  };
}
