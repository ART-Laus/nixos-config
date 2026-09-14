{
  home.file.".config/nvim/lua/keymaps.lua".text = ''
    -- keymaps.lua
    (function()
      local opts = { noremap = true, silent = true }
      local keymap = vim.keymap

      vim.api.nvim_set_keymap("", "<C-s>", "<cmd>w<CR>", opts)
      vim.api.nvim_set_keymap("n", "/", ":", { noremap = true, silent = false })
      vim.api.nvim_set_keymap("v", "/", ":", { noremap = true, silent = false })

      keymap.set("n", "=", "<C-a>", { noremap = true, silent = true })
      keymap.set("n", "-", "<C-x>", { noremap = true, silent = true })
      keymap.set("n", "dw", 'vb"_d')
      keymap.set("n", "<C-a>", "gg<S-v>G")
      keymap.set("n", "cl", "Yp", opts)
      keymap.set("v", "cl", "Yp", opts)
      vim.api.nvim_set_keymap("n", "sl", "^", opts)
      vim.api.nvim_set_keymap("n", "el", "$", opts)
      vim.api.nvim_set_keymap("v", "sl", "^", opts)
      vim.api.nvim_set_keymap("v", "el", "$", opts)
      keymap.set("n", "<A-S-j>", ":m .-2<CR>==", { noremap = true, silent = true })
      keymap.set("n", "<A-S-k>", ":m .+1<CR>==", { noremap = true, silent = true })
      keymap.set("v", "<A-S-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
      keymap.set("v", "<A-S-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
      keymap.set("n", "nw", "w", { noremap = true, silent = true })
      keymap.set("n", "bw", "b", { noremap = true, silent = true })
      keymap.set("n", "f(", "f(l", { noremap = true, silent = true })
      keymap.set("n", "f]", "f[l", { noremap = true, silent = true })
      keymap.set("n", "f}", "f{l", { noremap = true, silent = true })
      keymap.set("v", "<", "<gv", opts)
      keymap.set("v", ">", ">gv", opts)
      keymap.set("n", ".", "/", { noremap = true })
      keymap.set("n", ",", "?", { noremap = true })
      keymap.set("n", "m", "nzzzv")
      keymap.set("n", "M", "Nzzzv")
      keymap.set("i", "<C-m>", "<Esc>")
      keymap.set("n", "<C-m>", ":nohl<CR>", { desc = "Clear search hl", silent = true })
      keymap.set("n", "<Leader>h", ":bprevious<CR>", { silent = true })
      keymap.set("n", "<Leader>l", ":bnext<CR>", { silent = true })
      keymap.set("n", "<Leader>q", ":bdelete<CR>", { silent = true })
      keymap.set("n", "<Leader>lw", "<cmd>set wrap!<CR>", opts)

      local function smart_word_select()
        local mode = vim.fn.mode()
        if mode == "n" then
          vim.api.nvim_feedkeys("viw", "n", true)
        elseif mode == "v" then
          vim.api.nvim_feedkeys("w", "n", true)
        end
      end
      keymap.set({ "n", "v" }, "sw", smart_word_select, { noremap = true, silent = true, desc = "Инкрементальное выделение слов" })

      local function InteractiveReplace(scope)
        local search_term = vim.fn.getreg("/")
        if search_term == "" then
          print("Нет выражения для поиска в регистре.")
          return
        end
        local replacement = vim.fn.input('Заменить "' .. search_term .. '" на: ')
        if replacement == "" then
          print("Замена отменена.")
          return
        end
        local flags = ""
        if scope == "all" then
          flags = "g"
        end
        local escaped_search_term = vim.fn.escape(search_term, "/")
        local cmd_prefix = "%"
        if scope == "line" then
          cmd_prefix = ""
        end
        vim.cmd(cmd_prefix .. "s/" .. escaped_search_term .. "/" .. replacement .. "/" .. flags)
      end

      keymap.set("n", "<leader>ra", function() InteractiveReplace("all") end, { noremap = true, silent = true, desc = "Заменить все вхождения последнего поиска" })
      keymap.set("n", "<leader>rw", function() InteractiveReplace("line") end, { noremap = true, silent = true, desc = "Заменить на текущей строке" })
    end)()
  '';
}