{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = langmapper-nvim;
    config = ''
      require("langmapper").setup()
    '';
  }
]
