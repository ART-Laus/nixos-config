{
  home.file.".config/nvim/lua/plugins/telescope.lua".text = ''
    return {
      "nvim-telescope/telescope.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope-themes",
        "nvim-telescope/telescope-zoxide",
      },
      config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.load_extension("themes")
        telescope.load_extension("zoxide")

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
          extensions = {
            themes = {
              enable_previewer = true,
              enable_live_preview = true,
            },
          },
        })

        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help Tags" })
        vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Find Old Files" })
        vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under Cursor" })
        vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })
        vim.keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy Find in Current Buffer" })

        vim.keymap.set("n", "<leader>thm", function()
          telescope.extensions.themes.themes()
        end, { desc = "Theme Switcher" })

        vim.keymap.set("n", "<leader>z", function()
          telescope.extensions.zoxide.list()
        end, { desc = "Zoxide list" })
      end
    }
  '';
}