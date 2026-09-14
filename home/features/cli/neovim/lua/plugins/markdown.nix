{ ... }:

{
  home.file.".config/nvim/lua/plugins/markdown.lua".text = ''
    return {
      {
        "MeanderingProgrammer/markdown.nvim",
        name = "render-markdown",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "User FilePost",
        ft = "markdown",
        config = function()
          require("render-markdown").setup({})
        end,
        keys = {
          { "<Leader>md", "<CMD>RenderMarkdown toggle<CR>", mode = { "n" }, desc = "markdown toggle preview" },
        },
      },
      {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown", "vimwiki" },
        build = function()
          vim.fn["mkdp#util#install"]()
        end,
        config = function()
          vim.g.mkdp_auto_start = 1
          vim.g.mkdp_auto_close = 1
          vim.g.mkdp_refresh_interval = 500
          vim.g.mkdp_page_title = "$ {name}"
          vim.g.mkdp_browser = "chromium"
        end,
        keys = {
          { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
        },
      },
    }
  '';
}
