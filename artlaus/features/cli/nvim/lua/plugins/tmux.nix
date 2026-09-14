{ config, pkgs, ... }:

{
  config.programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
    ];
  };
}
