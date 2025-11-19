{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "mikavilpas";
  repo = "yazi.nvim";
  rev = "56a8c4de40cf2d40bcab93ff45e24beff81332e6";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  event = "VeryLazy";
      keys = [
        {
          key = "<leader>n";
          action = "<cmd>Yazi<cr>";
          options = { desc = "Open yazi at the current file"; };
        }
        {
          key = "<leader>cw";
          action = "<cmd>Yazi cwd<cr>";
          options = { desc = "Open the file manager in nvim's working directory"; };
        }
        {
          key = "<c-up>";
          action = "<cmd>Yazi toggle<cr>";
          options = { desc = "Resume the last yazi session"; };
        }
      ];
      config = ''
        require("yazi").setup({
          open_for_directories = false,
          keymaps = {
            show_help = "<F1>",
          },
          yazi_floating_window_border = "none",
        })
      '';
})
