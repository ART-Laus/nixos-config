{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = nvim-treesitter;
    config = ''
      local ts_init = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", true)[1]
      if ts_init then
        local ts_root = vim.fn.fnamemodify(ts_init, ":h:h:h")
        vim.opt.rtp:append(ts_root .. "/runtime")
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua", "vim", "query", "sh", "json", "yaml", "toml", "nix",
          "markdown", "regex", "c", "cpp", "python", "javascript",
          "typescript", "html", "css", "rust",
        },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    '';
  }
]
