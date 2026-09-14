# theme/fonts.nix — единый источник шрифтов
{
  # UI (GTK, Waybar, Rofi, SwayNC)
  ui = {
    name = "JetBrainsMono Nerd Font";
    size = 14;
    fallback = [ "Noto Sans" "Cantarell" ];
  };

  # Terminal / Neovim / monospace
  mono = {
    name = "JetBrainsMono Nerd Font";
    size = 14.0;
    fallback = [ "Noto Sans Mono" "DejaVu Sans Mono" ];
  };

  # Nerd Font glyphs (иконки в Waybar, Neovim, Yazi)
  nerd = {
    name = "JetBrainsMono Nerd Font";
  };

  # Emoji
  emoji = {
    name = "Noto Color Emoji";
  };
}
