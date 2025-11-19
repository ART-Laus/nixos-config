{ config, pkgs, ... }:

{
  programs.neovim.extraLuaConfig = ''
    -- Autocommands from config/autocmds.lua
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.lua",
      callback = function()
        local file = vim.fn.expand("<afile>")
        if file:match("init.lua") or file:match("lua/config/") then
          vim.cmd("silent source " .. file)
        end
      end,
    })
  '';
}
