# home/features/desktop/launcher/rofi.nix — Rofi launcher (тема из theme/colors.nix)
{ config, pkgs, lib, theme, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${pkgs.wezterm}/bin/wezterm";
    theme = let
      inherit (theme) colors;
    in {
      "*" = {
        background-color = colors.bg;
        text-color = colors.fg;
        border-color = colors.primary;
      };
      "window" = {
        background-color = colors.bgTransparent or colors.bg;
        border = "2px";
        border-radius = "8px";
      };
      "element selected.normal" = {
        background-color = colors.primary;
        text-color = colors.bg;
      };
    };
  };

  # Rofi-media scripts — из scripts/
  home.packages = with pkgs; [
    (import ../../../../scripts { inherit pkgs; })
  ];
}
