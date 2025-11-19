{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "mfussenegger";
  repo = "nvim-lint";
  rev = "baf7c91c2b868b12446df511d4cdddc98e9bf66e";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  config = ''
    local lint = require("lint")
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
    lint.linters_by_ft = {
      astro = { "eslint_d" };
      javascript = { "eslint_d" };
      svelte = { "eslint_d" };
      typescript = { "eslint_d" };
      typescriptreact = { "eslint_d" };
      html = { "eslint_d" };
      templ = { "eslint_d" };
      tsx = { "eslint_d" };
      python = { "flake8" };
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
  '';
})
