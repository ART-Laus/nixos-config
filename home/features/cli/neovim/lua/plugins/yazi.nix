{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = yazi-nvim;
    config = ''
      require("yazi").setup({
        open_for_directories = false,
        keymaps = {
          show_help = "<f1>",
        },
        open_file_function = function(chosen_file)
          vim.cmd(string.format("drop %s", vim.fn.fnameescape(chosen_file)))
        end,
        yazi_floating_window_border = "none",
      })
    '';
  }
]
