{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "Wansmer";
  repo = "langmapper.nvim";
  rev = "57a2fe4d706676aa0386825f27c27a4e3c14e0b0";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  lazy = false;
  priority = 1;
  config = '' require('langmapper').setup() '';
})
