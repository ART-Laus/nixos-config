{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "numToStr";
  repo = "Comment.nvim";
  rev = "e30b7f2008e52442154b66f7c519bfd2f1e32acb";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  config = ''
    require("ts_context_commentstring").setup({
      enable_autocmd = false,
    })
    require("Comment").setup({
      padding = true,
      sticky = true,
      toggler = {
        line = "<leader>c",
        block = "<leader>C",
      },
      opleader = {
        line = "<leader>c",
        block = "<leader>C",
      },
      extra = {
        above = "gcO",
        below = "gco",
        eol = "gcA",
      },
      mappings = {
        basic = true,
        extra = true,
      },
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    })
  '';
})
