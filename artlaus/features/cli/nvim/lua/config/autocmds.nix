{
  home.file.".config/nvim/lua/autocmds.lua".text = ''
    -- autocmds.lua
    (function()
      -- NOTE: This autocmd is meant to reload Lua configuration on save.
      -- In a Nix-managed setup, this is not idiomatic. The configuration
      -- should be reloaded by rebuilding the home-manager environment.
      -- This is kept for direct translation purposes but should be reconsidered.
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.lua",
        callback = function()
          local file = vim.fn.expand("<afile>")
          if file:match("init.lua") or file:match("lua/config/") then
            pcall(vim.cmd, "silent source " .. file)
          end
        end,
      })
    end)()
  '';
}