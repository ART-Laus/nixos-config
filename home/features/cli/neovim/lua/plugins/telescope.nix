{ pkgs, theme, ... }:

with pkgs.vimPlugins;
[
  {
    type = "lua";
    plugin = telescope-nvim;
    config = ''
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          path_display = { "smart" },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
            },
          },
        },
      })

      pcall(telescope.load_extension, "zoxide")
      pcall(telescope.load_extension, "fzf")

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find Old Files" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under Cursor" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })
      vim.keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy Find in Current Buffer" })

      vim.keymap.set("n", "<leader>thm", builtin.colorscheme, { desc = "Theme Switcher" })

      vim.keymap.set("n", "<leader>z", function()
        if telescope.extensions.zoxide then
          telescope.extensions.zoxide.list()
        end
      end, { desc = "Zoxide list" })
    '';
  }
]
