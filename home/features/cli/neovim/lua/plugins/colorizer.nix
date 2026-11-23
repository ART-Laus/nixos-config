{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = nvim-colorizer-lua;
    config = ''
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
          sass = { enable = false, parsers = { "css" } },
          virtualtext = "▌",
          always_update = false,
        },
        buftypes = {},
      })
    '';
  }
]
