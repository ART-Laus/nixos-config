{ theme, ... }:

let
  c = theme.colors;
in
{
  home.file.".config/nvim/lua/plugins/lualine.lua".text = ''
    return {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        local black = "${c.bg}"

        require("lualine").setup({
          options = {
            theme = {
               normal = {
                a = { fg = "${c.primary}", bg = black, gui = "bold" },
                b = { fg = "${c.fg}", bg = black },
                c = { fg = "${c.fg}", bg = black },
              },
              insert = {
                a = { fg = "${c.pink}", bg = black, gui = "bold" },
                b = { fg = "${c.lightPink}", bg = black },
                c = { fg = "${c.lightPink}", bg = black },
              },
              visual = {
                a = { fg = "${c.cyan}", bg = black, gui = "bold" },
                b = { fg = "${c.lightBlue}", bg = black },
                c = { fg = "${c.lightBlue}", bg = black },
              },
              command = {
                a = { fg = "${c.secondary}", bg = black, gui = "bold" },
                b = { fg = "${c.lightLavender}", bg = black },
                c = { fg = "${c.lightLavender}", bg = black },
              },
              inactive = {
                a = { fg = "${c.gray}", bg = black },
                b = { fg = "${c.gray}", bg = black },
                c = { fg = "${c.gray}", bg = black },
              },
            },
            section_separators = { left = "", right = "" },
            component_separators = { left = " ", right = " " },
            globalstatus = true,
            icons_enabled = true,
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
          },
        })

        vim.api.nvim_set_hl(0, "lualine_a_separator", { fg = black, bg = black })
        vim.api.nvim_set_hl(0, "lualine_b_separator", { fg = black, bg = black })
        vim.api.nvim_set_hl(0, "lualine_c_separator", { fg = black, bg = black })
        vim.api.nvim_set_hl(0, "lualine_x_separator", { fg = black, bg = black })
        vim.api.nvim_set_hl(0, "lualine_y_separator", { fg = black, bg = black })
      end
    }
  '';
}