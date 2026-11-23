{
  home.file.".config/nvim/lua/core/autocmds.lua".text = ''
    (function()
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.highlight.on_yank({ timeout = 150 })
        end,
      })
    end)()
  '';
}
