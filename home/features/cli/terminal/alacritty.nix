{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
in

{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        decorations = "none";
        padding = { x = 0; y = 0; };
        opacity = 0.85;
      };

      font = {
        normal = { family = "JetBrains Mono"; };
        size = 14.0;
      };

      cursor = {
        style = "Underline";
        blinking = "On";
      };

      colors = {
        primary = {
          background = c.bg;
          foreground = c.fg;
        };

        cursor = {
          text = c.bg;
          cursor = c.primary;
        };

        selection = {
          text = c.bg;
          background = c.primary;
        };

        normal = {
          black   = c.bgAlt;
          red     = c.error;
          green   = c.success;
          yellow  = c.warning;
          blue    = c.accentBlue;
          magenta = c.secondary;
          cyan    = c.accentBlue;
          white   = c.fg;
        };

        bright = {
          black   = c.bgAlt;
          red     = c.error;
          green   = c.success;
          yellow  = c.warning;
          blue    = c.accentBlue;
          magenta = c.secondary;
          cyan    = c.accentBlue;
          white   = c.fg;
        };
      };
    };
  };
}
