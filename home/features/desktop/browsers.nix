# home/features/desktop/browsers.nix — браузеры + соцсети + почта
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox
    chromium
    librewolf
    thunderbird

    # Соцсети (было pkgs2.discord / telegram-desktop)
    discord
    telegram-desktop
  ];
}
