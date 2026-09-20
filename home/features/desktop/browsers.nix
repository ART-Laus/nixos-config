# home/features/desktop/browsers.nix — браузеры
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox
  ];
}
