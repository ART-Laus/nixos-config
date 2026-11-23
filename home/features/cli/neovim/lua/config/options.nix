{
  home.file.".config/nvim/lua/core/options.lua".text = ''
    (function()
      local opt = vim.opt

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
      opt.wrap = false
      opt.scrolloff = 8
      opt.sidescrolloff = 8
      opt.splitright = true
      opt.splitbelow = true
      opt.mouse = "a"
      opt.backspace = "start,eol,indent"
      opt.isfname:append("@-@")
      opt.hlsearch = true
      opt.incsearch = true
      opt.inccommand = "split"
      opt.wildmenu = true
      opt.wildmode = "longest:full,full"
    end)()
  '';
}
