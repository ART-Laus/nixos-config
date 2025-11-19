{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "nvim-lua";
  repo = "plenary.nvim";
  rev = "b9fd5226c2f76c951fc8ed5923d85e4de065e509";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
})
