# home/features/desktop/notifications/dunst.nix — уведомления (тема из theme)
{ config, pkgs, lib, theme, ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 10;
        frame_color = theme.colors.primary;
        font = "${theme.fonts.ui.name} 10";
        background = theme.colors.bg;
        foreground = theme.colors.fg;
      };
      urgency_low = {
        background = theme.colors.bg;
        foreground = theme.colors.muted;
      };
      urgency_normal = {
        background = theme.colors.bg;
        foreground = theme.colors.fg;
      };
      urgency_critical = {
        background = theme.colors.error;
        foreground = theme.colors.bg;
        frame_color = theme.colors.error;
      };
    };
  };
}
