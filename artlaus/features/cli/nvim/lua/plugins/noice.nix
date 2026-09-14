{
  home.file.".config/nvim/lua/plugins/noice.lua".text = ''
    return {
      "folke/noice.nvim",
      config = function()
        require("noice").setup({
          lsp = {
            signature = {
              enabled = true,
              auto_open = {
                enabled = true,
                trigger = true,
                luasnip = true,
                throttle = 50,
              },
              view = nil,
              opts = {},
            },
            override = {},
          },

          cmdline = {
            enabled = true,
            view = "cmdline_popup",
            format = {
              cmdline = { pattern = "^:", icon = "", lang = "vim" },
              search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
              search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
            },
          },

          views = {
            cmdline_popup = {
              position = { row = "10%", col = "50%" },
              size = { width = "60%", height = "auto" },
              border = { style = "rounded", padding = { 0, 1 } },
              win_options = {
                winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
              },
            },
          },

          routes = {
            {
              filter = {
                event = "msg_show",
                any = {
                  { find = "%d+L, %d+B" },
                  { find = "; after #%d+" },
                  { find = "; before #%d+" },
                },
              },
              view = "mini",
            },
          },

          presets = {
            bottom_search = false,
            command_palette = true,
            long_message_to_split = true,
          },
        })
        
        if vim.o.filetype == "lazy" then
          vim.cmd([[messages clear]])
        end
        
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "NONE", fg = "#66FF99" })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#58FFD6", bg = "NONE" })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#58FFD6", bg = "NONE" })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#66FF99", bg = "NONE", bold = true })
      end
    }
  '';
}