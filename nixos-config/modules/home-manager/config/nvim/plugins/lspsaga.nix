{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "glepnir";
  repo = "lspsaga.nvim";
  rev = "8efe00d6aed9db6449969f889170f1a7e43101a1";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  event = "LspAttach";
  config = '' require("lspsaga").setup({}) '';
})
