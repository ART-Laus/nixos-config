{ config, pkgs, lib, theme, ... }:

{
  imports = [
    ./init.nix
    ./lua/config/default.nix
    ./lua/plugins/default.nix
  ];

  programs.neovim = {
    enable = true;
    # Install lazy.nvim itself as a home-manager plugin.
    plugins = [ pkgs.vimPlugins.lazy-nvim ];
  };
}
