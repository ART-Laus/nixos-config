{
  home.file.".config/nvim/lua/plugins/alpha.lua".text = ''
    return {
      "goolord/alpha-nvim",
      config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
          "Welcome, Ilya!"
        }

        dashboard.section.buttons.val = {
          dashboard.button("e", "  New Protocol", ":ene <BAR> startinsert <CR>"),
          dashboard.button("b", "  File Matrix", ":Yazi<CR>"),
          dashboard.button("z", "󱂬  Directory Grid", ":Telescope zoxide list<CR>"),
          dashboard.button("f", "  Locate Node", ":Telescope find_files<CR>"),
          dashboard.button("r", "󰄉  Recent Access", ":Telescope oldfiles<CR>"),
          dashboard.button("s", "󰒒  Session Core", ":Yazi toggle<CR>"),
          dashboard.button("l", "󰒲  Lazy Reactor", ":Lazy<CR>"),
          dashboard.button("q", "⏻  System Shutdown", ":qa<CR>"),
        }
        alpha.setup(dashboard.opts)
      end
    }
  '';
}