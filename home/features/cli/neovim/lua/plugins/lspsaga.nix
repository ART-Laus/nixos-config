{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = lspsaga-nvim;
    config = ''
      require("lspsaga").setup({})
    '';
  }
]
