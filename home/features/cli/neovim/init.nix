{ config, pkgs, ... }:

{
  programs.neovim.extraLuaConfig = ''
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
  '';

  home.file.".config/nvim/lua/init.lua".text = ''
    -- init.lua
    -- Загрузка цветовой схемы
    vim.cmd("colorscheme artgreendream")

    -- Load your configuration files
    require("options")
    require("keymaps")
    require("autocmds")
    require("lazy") -- This calls lazy.setup()

    -- Load your plugin configurations (which lazy.nvim will pick up)
    -- This is implicitly handled by lazy.nvim's `import = "plugins"`
  '';
}