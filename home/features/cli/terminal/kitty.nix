{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      font_family = "JetBrains Mono";
      font_size = 14;
      background_opacity = "0.85";
      confirm_os_window_close = 0;
      scrollback_lines = 50000;
      enable_audio_bell = false;
      confirm_window_close = 0;
    };

    extraConfig = ''
      # Colors — Artlaus Neon (Green #66FF99 + Lavender #C4A0FF + AMOLED #001a0d)
      background #001a0d
      foreground #C0FFC0

      cursor #66FF99
      cursor_text #0A0A0F

      selection_background #66FF99
      selection_foreground #0A0A0F

      black #1E1E2E
      red #FF007C
      green #00FF9F
      yellow #FFD500
      blue #00BFFF
      magenta #B400FF
      cyan #00FFFF
      white #C0C0C0

      bright_black #2E2E3E
      bright_red #FF3399
      bright_green #33FFB2
      bright_yellow #FFE066
      bright_blue #33CFFF
      bright_magenta #CC66FF
      bright_cyan #66FFFF
      bright_white #FFFFFF
    '';
  };
}
