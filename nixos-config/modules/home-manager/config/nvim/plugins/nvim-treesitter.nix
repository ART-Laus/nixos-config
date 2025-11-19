{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "nvim-treesitter";
  repo = "nvim-treesitter";
  rev = "42fc28ba918343ebfd5565147a42a26580579482";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  build = ":TSUpdate";
  config = ''
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'lua','vim','query',
        'bash','json','yaml','toml','markdown','regex',
        'c','cpp','python',
        'javascript','typescript','html','css',
        'rust',
      },
      highlight = { enable = true },
    }
  '';
})
