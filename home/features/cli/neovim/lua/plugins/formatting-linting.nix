{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = conform-nvim;
    config = ''
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          nix = { "nixpkgs-fmt" },
          rust = { "rustfmt" },
        },

        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback",
          quiet = true,
        },
      })
    '';
  }
  {
    type = "lua";
    plugin = nvim-lint;
    config = ''
      local lint = require("lint")

      lint.linters_by_ft = {}

      local function safe_lint()
        local ok = pcall(lint.try_lint)
        if not ok then
          vim.schedule(function()
            vim.api.nvim_echo({
              { "lint skipped (tool not configured)", "WarningMsg" },
            }, false, {})
          end)
        end
      end

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = safe_lint,
      })
    '';
  }
]
