{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = render-markdown-nvim;
    config = ''
      require("render-markdown").setup({})
      vim.keymap.set("n", "<Leader>md", "<CMD>RenderMarkdown toggle<CR>", { desc = "markdown toggle preview" })
    '';
  }
  {
    type = "lua";
    plugin = markdown-preview-nvim;
    config = ''
      vim.g.mkdp_auto_start = 1
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_interval = 500
      vim.g.mkdp_page_title = "$" .. "{name}"
      vim.g.mkdp_browser = "chromium"
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })
    '';
  }
]
