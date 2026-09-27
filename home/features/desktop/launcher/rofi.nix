# home/features/desktop/launcher/rofi.nix — Rofi launcher (тема из theme/colors.nix)
{ config, pkgs, lib, theme, ... }:
let
  scripts = import ../../../../scripts { inherit pkgs; };
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${pkgs.alacritty}/bin/alacritty";
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

  # Rofi-media scripts + automation menu — из scripts/
  home.packages = with pkgs; [
    scripts.rofi-image
    scripts.rofi-video
    scripts.rofi-audio
    scripts.automation-menu
  ];
}
