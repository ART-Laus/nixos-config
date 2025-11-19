{ config, pkgs, ... }:

{
  imports = [
    ./config/options.nix
    ./config/keymaps.nix
    ./config/autocmds.nix
    ./plugins
    ./extra-packages.nix
    ./init.nix
    ./colors/artgreendream.nix # Assuming this will be a Nix module for the colorscheme
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
