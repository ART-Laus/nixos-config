{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "nvim-lualine";
  repo = "lualine.nvim";
  rev = "3946f0122255bc377d14a59b27b609fb3ab25768";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  config = ''
    local black = "#000000"
    require("lualine").setup({
      options = {
        theme = {
          normal = {
            a = { fg = "#66FF99", bg = black, gui = "bold" },
            b = { fg = "#C0FFC0", bg = black },
            c = { fg = "#C0FFC0", bg = black },
          },
          insert = {
            a = { fg = "#FF66CC", bg = black, gui = "bold" },
            b = { fg = "#FFBBDD", bg = black },
            c = { fg = "#FFBBDD", bg = black },
          },
          visual = {
            a = { fg = "#88DDFF", bg = black, gui = "bold" },
            b = { fg = "#B0E8FF", bg = black },
            c = { fg = "#B0E8FF", bg = black },
          },
          command = {
            a = { fg = "#C4A0FF", bg = black, gui = "bold" },
            b = { fg = "#D4B8FF", bg = black },
            c = { fg = "#D4B8FF", bg = black },
          },
          inactive = {
            a = { fg = "#666666", bg = black },
            b = { fg = "#666666", bg = black },
            c = { fg = "#666666", bg = black },
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
    vim.api.nvim_set_hl(0, "lualine_z_separator", { fg = black, bg = black })
  '';
})
