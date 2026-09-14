{
  home.file.".config/nvim/lua/lazy.lua".text = ''
    -- lazy.lua
    -- NOTE: Bootstrapping of lazy.nvim is handled by home-manager.
    -- We only need to provide the setup configuration.
    (function()
      require("lazy").setup({
        spec = {
          { import = "plugins" },
        },
        defaults = { lazy = false },
        checker = { enabled = false, notify = false },
        ui = { border = "rounded" },
      })
    end)()
  '';
}