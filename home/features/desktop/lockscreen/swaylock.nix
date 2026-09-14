# home/features/desktop/lockscreen/swaylock.nix — экран блокировки
{ config, pkgs, lib, theme, ... }:
{
  programs.swaylock = {
    enable = true;
    settings = {
      color = builtins.substring 1 6 theme.colors.bg;
      font = theme.fonts.ui.name;
      indicator-radius = 100;
      indicator-thickness = 7;
      inside-color = theme.colors.bg;
      inside-clear-color = theme.colors.bg;
      inside-caps-lock-color = theme.colors.warning;
      inside-ver-color = theme.colors.primary;
      inside-wrong-color = theme.colors.error;
      key-hl-color = theme.colors.primary;
      bs-hl-color = theme.colors.error;
      ring-color = theme.colors.muted;
      ring-clear-color = theme.colors.warning;
      ring-caps-lock-color = theme.colors.warning;
      ring-ver-color = theme.colors.primary;
      ring-wrong-color = theme.colors.error;
      text-color = theme.colors.fg;
      text-clear-color = theme.colors.fg;
      text-ver-color = theme.colors.fg;
      text-wrong-color = theme.colors.fg;
      show-failed-attempts = true;
    };
  };
}
