{
  home.file.".config/nvim/lua/plugins/formatting_linting.lua".text = ''
    return {
      {
        "stevearc/conform.nvim",
        config = function()
          require("conform").setup({
              formatters_by_ft = {
                  astro = { "prettierd" },
                  css = { "prettierd" },
                  html = { "prettierd" },
                  templ = { "prettierd" },
                  javascript = { "prettierd" },
                  javascriptreact = { "prettierd" },
                  typescript = { "prettierd" },
                  typescriptreact = { "prettierd" },
                  tsx = { "prettierd" },
                  json = { "prettierd" },
                  jsonc = { "prettierd" },
                  lua = { "stylua" },
                  mdx = { "prettierd" },
                  nix = { "nixfmt" },
                  python = { "isort", "black" },
                  rust = { "rustfmt" },
                  svelte = { "prettierd" },
                  verilog = { "verible" },
                  typst = { "typstyle" },
                  yaml = { "prettierd" },
              },

              format_after_save = {
                  lsp_fallback = true,
                  quiet = true,
              },

              formatters = {
                  gdformat = {
                      command = "gdformat",
                      args = "$FILENAME",
                      stdin = false,
                  },
                  verible = {
                      command = "verible-verilog-format",
                      prepend_args = { "--indentation_spaces", "4" },
                  },
              },
          })
        end
      },
      {
        "mfussenegger/nvim-lint",
        config = function()
          local lint = require("lint")
          local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
          vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

          lint.linters_by_ft = {
              astro = { "eslint_d" },
              javascript = { "eslint_d" },
              svelte = { "eslint_d" },
              typescript = { "eslint_d" },
              typescriptreact = { "eslint_d" },
              html = { "eslint_d" },
              templ = { "eslint_d" },
              tsx = { "eslint_d" },
              python = { "flake8" },
          }

          local function safe_lint()
              local ok = pcall(lint.try_lint)
              if not ok then
                  vim.schedule(function()
                      vim.api.nvim_echo({
                          { "⚠ lint skipped (tool not found)", "WarningMsg" },
                      }, false, {})
                  end)
              end
          end

          vim.api.nvim_create_autocmd({ "BufWritePost" }, {
              callback = function()
                  safe_lint()
              end,
          })
        end
      }
    }
  '';
}