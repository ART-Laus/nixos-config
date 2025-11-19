{ config, pkgs, ... }:

{
  programs.neovim.extraLuaConfig = ''
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    -- Colorscheme from init.lua
    vim.cmd("colorscheme artgreendream")
  '';
}
