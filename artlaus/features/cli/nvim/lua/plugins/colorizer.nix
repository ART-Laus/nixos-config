{
  home.file.".config/nvim/lua/plugins/colorizer.lua".text = ''
    return {
      "NvChad/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup({
          filetypes = { "*" },
          user_default_options = {
            RGB = true,
            RRGGBB = true,
            names = false,
            RRGGBBAA = true,
            AARRGGBB = true,
            rgb_fn = true,
            hsl_fn = true,
            css = false,
            css_fn = false,
            mode = "virtualtext",
            virtualtext_inline = true,
            tailwind = false,
            sass = { enable = false, parsers = { "css" }, },
            virtualtext = "▌",
            always_update = false
          },
          buftypes = {},
        })
      end
    }
  '';
}