# home/features/desktop/browsers.nix — браузеры + соцсети
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox
    chromium
    librewolf

    # Соцсети
    discord
    ayugram-desktop
  ];
}
