{ config, pkgs, lib, theme, ... }:

{
  imports = [
    ./init.nix
    ./lua/config/default.nix
    ./lua/plugins/default.nix
  ];

  programs.neovim = {
    enable = true;
  };
}
