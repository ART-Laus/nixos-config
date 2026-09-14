{
  home.file.".config/nvim/lua/options.lua".text = ''
    -- options.lua
    (function()
      local opt = vim.opt
      local data_path = vim.fn.stdpath("data")

      opt.number = true
      opt.relativenumber = true
      opt.cursorline = true
      opt.cursorcolumn = false
      opt.signcolumn = "yes"
      opt.expandtab = true
      opt.shiftwidth = 4
      opt.tabstop = 4
      opt.smartindent = true
      opt.autoindent = true
      opt.termguicolors = true
      opt.background = "dark"
      opt.clipboard = "unnamedplus"
      opt.undofile = true
      opt.ignorecase = true
      opt.smartcase = true
      opt.swapfile = false
      opt.backup = false
      opt.writebackup = false
      opt.undofile = false
      opt.wrap = false
      opt.scrolloff = 8
      opt.sidescrolloff = 8
      opt.splitright = true
      opt.splitbelow = true
      opt.mouse = "a"
      vim.opt.backspace = "start,eol,indent"
      vim.opt.isfname:append("@-@")
      vim.opt.hlsearch = true
      vim.opt.incsearch = true
      vim.opt.inccommand = "split"
      vim.opt.wildmenu = true
      vim.opt.wildmode = "longest:full,full"

      -- NOTE: swap, undo, and backup directories are managed by Nix/Home-manager,
      -- so the manual directory creation part is removed.
    end)()
  '';
}