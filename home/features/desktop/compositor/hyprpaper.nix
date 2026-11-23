# home/features/desktop/compositor/hyprpaper.nix — обои
{ config, pkgs, lib, theme, ... }:
let
  solidWallpaper = pkgs.runCommand "artlaus-solid-wallpaper" { } ''
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 xc:'${theme.colors.bg}' png:$out
  '';
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ (builtins.toString solidWallpaper) ];
      wallpaper = [
        {
          monitor = "*";
          path = builtins.toString solidWallpaper;
        }
      ];
    };
  };
}
