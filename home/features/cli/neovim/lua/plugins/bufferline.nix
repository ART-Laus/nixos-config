{
  home.file.".config/nvim/lua/plugins/bufferline.lua".text = ''
    return {
      'akinsho/bufferline.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        vim.cmd("colorscheme artgreendream")

        require("bufferline").setup({
          options = {
            mode = "buffers",
            separator_style = { "", "" },
            always_show_bufferline = true,
            show_buffer_close_icons = false,
            show_close_icon = false,
            color_icons = true,
            tab_size = 20,
            max_name_length = 25,
            truncate_names = true,
            enforce_regular_tabs = true,
            modified_icon = "●",

            indicator = {
                style = "icon",
                icon = "▎",
            },
          },
          highlights = {
            fill = { bg = "none" },
            background = { bg = "none" },
            buffer_visible = { bg = "none" },
            buffer_selected = {
                bg = "none",
                bold = true,
                italic = false,
            },
            indicator_selected = { fg = "#00ff99", bg = "none" },
            modified = { fg = "#EF5350" },
            modified_selected = { fg = "#EF5350" },
            modified_visible = { fg = "#EF5350" },
            separator = { fg = "none", bg = "none" },
            separator_selected = { fg = "none", bg = "none" },
          },
        })

        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
        vim.api.nvim_set_hl(0, "BufferLineFill", { bg = "none" })
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
      end
    }
  '';
}