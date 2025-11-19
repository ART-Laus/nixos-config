{ config, pkgs, ... }:

{
  # Link the colorscheme file
  # Assuming artgreendream is a Lua file. If it's vimscript, change the extension.
  home.file.".config/nvim/colors/artgreendream.lua".source = ./artgreendream.lua;
}
