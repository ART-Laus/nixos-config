{ config, pkgs, ... }:

{
  programs.neovim.settings = {
    # Global Neovim options from config/options.lua
    number = true;
    relativenumber = true;
    cursorline = true;
    cursorcolumn = false;
    signcolumn = "yes";
    expandtab = true;
    shiftwidth = 4;
    tabstop = 4;
    smartindent = true;
    autoindent = true;
    termguicolors = true;
    background = "dark";
    clipboard = "unnamedplus";
    undofile = true;
    ignorecase = true;
    smartcase = true;
    swapfile = true;
    backup = true;
    wrap = false;
    scrolloff = 8;
    sidescrolloff = 8;
    splitright = true;
    splitbelow = true;
    mouse = "a";
    backspace = "start,eol,indent";
    hlsearch = true;
    incsearch = true;
    inccommand = "split";
    wildmenu = true;
    wildmode = "longest:full,full";
  };

  # Swap/Undo/Backup directories (from config/options.lua)
  # These need to be handled as home.file or extraLuaConfig
  programs.neovim.extraLuaConfig = ''
    local data_path = vim.fn.stdpath("data")
    for _, dir in ipairs({ "swap", "undo", "backup" }) do
      local path = data_path .. "/" .. dir
      if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
      end
    end
    vim.opt.directory = data_path .. "/swap//"
    vim.opt.backupdir = data_path .. "/backup//"
    vim.opt.undodir = data_path .. "/undo//"
  '';
}
