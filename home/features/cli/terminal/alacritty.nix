{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    # Конфигурация Alacritty
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
          background = "#001a0d";
          foreground = "#C0FFC0";
        };

        cursor = {
          text = "#0A0A0F";
          cursor = "#66FF99";
        };

        selection = {
          text = "#0A0A0F";
          background = "#66FF99";
        };

        normal = {
          black =   "#1E1E2E";
          red =     "#FF007C";
          green =   "#00FF9F";
          yellow =  "#FFD500";
          blue =    "#00BFFF";
          magenta = "#B400FF";
          cyan =    "#00FFFF";
          white =   "#C0C0C0";
        };

        bright = {
          black =   "#2E2E3E";
          red =     "#FF3399";
          green =   "#33FFB2";
          yellow =  "#FFE066";
          blue =    "#33CFFF";
          magenta = "#CC66FF";
          cyan =    "#66FFFF";
          white =   "#FFFFFF";
        };
      };
    };
  };
}
