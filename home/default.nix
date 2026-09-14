# home/default.nix — Home Manager для artlaus (новый путь)
# Импортирует все features из home/features/* (полная иерархия, всё сразу)
{ config, pkgs, lib, theme, ... }:
{
  imports = [
    # Core — тема, XDG, окружение (единый стиль из theme/)
    ./gtk-qt.nix

    # Features — все кубики сразу в правильных местах (иерархия, не плоско)
    ./features/cli
    ./features/desktop
    ./features/development
    ./features/media
    ./features/gaming
  ];

  # Совместимость: старые модули artlaus/* ожидают config.artlaus.cli.enable
  options.artlaus.cli.enable = lib.mkEnableOption "CLI (compat)" // { default = true; };

  config = {
    # Home Manager meta
    programs.home-manager.enable = true;

    home = {
      username = "artlaus";
      homeDirectory = "/home/artlaus";
      stateVersion = "25.05";
      sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "firefox";
        TERMINAL = "wezterm";
      };
    };
  };

  # Feature flags — единое место (переопределяются в hosts/msi-laptop/default.nix)
  # features.gaming.enable = true; # пример
}
