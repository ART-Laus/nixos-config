{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
in

{
  programs.kitty = {
    enable = true;

    settings = {
      font_family = theme.fonts.mono.name;
      font_size = 14;
      background_opacity = "0.85";
      confirm_os_window_close = 0;
      scrollback_lines = 50000;
      enable_audio_bell = false;
      confirm_window_close = 0;
    };

    extraConfig = ''
      background ${c.bg}
      foreground ${c.fg}

      cursor ${c.primary}
      cursor_text ${c.bg}

      selection_background ${c.primary}
      selection_foreground ${c.bg}

      black ${c.darkGray}
      red ${c.error}
      green ${c.success}
      yellow ${c.warning}
      blue ${c.blue}
      magenta ${c.pink}
      cyan ${c.cyan}
      white ${c.fg}

      bright_black ${c.darkGrayBright}
      bright_red ${c.error}
      bright_green ${c.success}
      bright_yellow ${c.warning}
      bright_blue ${c.blue}
      bright_magenta ${c.pink}
      bright_cyan ${c.cyan}
      bright_white ${c.fg}
    '';
  };
}
