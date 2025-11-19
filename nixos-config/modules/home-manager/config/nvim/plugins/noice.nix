{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

(mkPlugin {
  owner = "folke";
  repo = "noice.nvim";
  rev = "7bfd942445fb63089b59f97ca487d605e715f155";
  sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
  lazy = false;
  opts = {
    lsp = {
      signature = {
        enabled = true;
        auto_open = {
          enabled = true;
          trigger = true;
          luasnip = true;
          throttle = 50;
        };
        view = null;
        opts = {};
      };
      override = {};
    };
    cmdline = {
      enabled = true;
      view = "cmdline_popup";
      format = {
        cmdline = { pattern = "^:"; icon = ""; lang = "vim"; };
        search_down = { kind = "search"; pattern = "^/"; icon = ""; lang = "regex"; };
        search_up = { kind = "search"; pattern = "^%?"; icon = ""; lang = "regex"; };
      };
    };
    views = {
      cmdline_popup = {
        position = { row = "10%"; col = "50%"; };
        size = { width = "60%"; height = "auto"; };
        border = { style = "rounded"; padding = [ 0 1 ]; };
        win_options = {
          winhighlight = { Normal = "NormalFloat"; FloatBorder = "FloatBorder"; };
        };
      };
    };
    routes = [
      {
        filter = {
          event = "msg_show";
          any = [
            { find = "%d+L, %d+B" };
            { find = "; after #%d+" };
            { find = "; before #%d+" };
          ];
        };
        view = "mini";
      };
    ];
    presets = {
      bottom_search = false;
      command_palette = true;
      long_message_to_split = true;
    };
  };
  config = ''
    if vim.o.filetype == "lazy" then
      vim.cmd([[messages clear]])
    end
    require("noice").setup(opts)
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = "NONE", fg = "#66FF99" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#58FFD6", bg = "NONE" })
    vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { fg = "#58FFD6", bg = "NONE" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#66FF99", bg = "NONE", bold = true })
  '';
  # Keybindings for noice.nvim
  extraLua = ''
    vim.keymap.set("n", "<leader>sn", "", { desc = "+noice" })
    vim.keymap.set("c", "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, { desc = "Redirect Cmdline" })
    vim.keymap.set("n", "<leader>snl", function() require("noice").cmd("last") end, { desc = "Noice Last Message" })
    vim.keymap.set("n", "<leader>snh", function() require("noice").cmd("history") end, { desc = "Noice History" })
    vim.keymap.set("n", "<leader>sna", function() require("noice").cmd("all") end, { desc = "Noice All" })
    vim.keymap.set("n", "<leader>snd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss All" })
    vim.keymap.set("n", "<leader>snt", function() require("noice").cmd("pick") end, { desc = "Noice Picker (Telescope/FzfLua)" })
    vim.keymap.set({ "i", "n", "s" }, "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, { silent = true, expr = true, desc = "Scroll Forward" })
    vim.keymap.set({ "i", "n", "s" }, "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, { silent = true, expr = true, desc = "Scroll Backward" })
  '';
})
