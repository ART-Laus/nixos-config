{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "catgoose";
  repo = "nvim-colorizer.lua";
  rev = "81e676d3203c9eb6e4c0ccf1eba1679296ef923f";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  event = "BufReadPre";
  opts = {
    filetypes = { "*" };
    user_default_options = {
      RGB = true;
      RRGGBB = true;
      names = false;
      RRGGBBAA = true;
      AARRGGBB = true;
      rgb_fn = true;
      hsl_fn = true;
      css = false;
      css_fn = false;
      mode = "virtualtext";
      virtualtext_inline = true;
      tailwind = false;
      sass = { enable = false; parsers = [ "css" ]; };
      virtualtext = "▌";
      always_update = false;
    };
    buftypes = {};
  };
})
