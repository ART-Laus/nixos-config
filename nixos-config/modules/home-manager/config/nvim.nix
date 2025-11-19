{ config, pkgs, ... }:

let
  # Helper to define plugins with fetchFromGitHub
  mkPlugin = { owner, repo, rev, sha256, ... } @args: {
    plugin = pkgs.vimPlugins.${repo} or (pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = repo;
      version = rev;
      src = pkgs.fetchFromGitHub {
        inherit owner repo rev sha256;
      };
      # Add other args like meta, buildInputs if necessary
    });
  } // (removeAttrs args [ "owner" "repo" "rev" "sha256" ]);

  # Helper to define plugins that are already in pkgs.vimPlugins
  mkBuiltinPlugin = { name, ... } @args: {
    plugin = pkgs.vimPlugins.${name};
  } // (removeAttrs args [ "name" ]);

  # List of plugins with their details from lazy-lock.json
  # SHA256 hashes are placeholders and need to be updated by the user
  pluginsList = [
    # Comment.nvim
    (mkPlugin {
      owner = "numToStr";
      repo = "Comment.nvim";
      rev = "e30b7f2008e52442154b66f7c519bfd2f1e32acb";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      config = ''
        require("ts_context_commentstring").setup({
          enable_autocmd = false,
        })
        require("Comment").setup({
          padding = true,
          sticky = true,
          toggler = {
            line = "<leader>c",
            block = "<leader>C",
          },
          opleader = {
            line = "<leader>c",
            block = "<leader>C",
          },
          extra = {
            above = "gcO",
            below = "gco",
            eol = "gcA",
          },
          mappings = {
            basic = true,
            extra = true,
          },
          pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })
      '';
    })

    # LuaSnip
    (mkPlugin {
      owner = "L3MON4D3";
      repo = "LuaSnip";
      rev = "3732756842a2f7e0e76a7b0487e9692072857277";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # alpha-nvim
    (mkPlugin {
      owner = "goolord";
      repo = "alpha-nvim";
      rev = "3979b01cb05734331c7873049001d3f2bb8477f4";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      event = "VimEnter";
      config = ''
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        dashboard.section.header.val = {
          "Welcome, Ilya!"
        }

        dashboard.section.buttons.val = {
          dashboard.button("e", "  New Protocol", ":ene <BAR> startinsert <CR>"),
          dashboard.button("b", "  File Matrix", ":Yazi<CR>"),
          dashboard.button("z", "󱂬  Directory Grid", ":Telescope zoxide list<CR>"),
          dashboard.button("f", "  Locate Node", ":Telescope find_files<CR>"),
          dashboard.button("r", "󰄉  Recent Access", ":Telescope oldfiles<CR>"),
          dashboard.button("s", "󰒒  Session Core", ":Yazi toggle<CR>"),
          dashboard.button("l", "󰒲  Lazy Reactor", ":Lazy<CR>"),
          dashboard.button("q", "⏻  System Shutdown", ":qa<CR>"),
        }
        alpha.setup(dashboard.opts)
      '';
    })

    # bufferline.nvim
    (mkPlugin {
      owner = "akinsho";
      repo = "bufferline.nvim";
      rev = "655133c3b4c3e5e05ec549b9f8cc2894ac6f51b3";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      config = ''
        vim.cmd("colorscheme artgreendream")
        require("bufferline").setup({
          options = {
            mode = "buffers",
            separator_style = { "", "" },
            always_show_bufferline = true,
            show_buffer_close_icons = false,
            show_close_icon = false,
            color_icons = true,
            tab_size = 20,
            max_name_length = 25,
            truncate_names = true,
            enforce_regular_tabs = true,
            modified_icon = "●",
            indicator = {
              style = "icon",
              icon = "▎",
            },
          },
          highlights = {
            fill = { bg = "none" },
            background = { bg = "none" },
            buffer_visible = { bg = "none" },
            buffer_selected = {
              bg = "none",
              bold = true,
              italic = false,
            },
            indicator_selected = { fg = "#00ff99", bg = "none" },
            modified = { fg = "#EF5350" },
            modified_selected = { fg = "#EF5350" },
            modified_visible = { fg = "#EF5350" },
            separator = { fg = "none", bg = "none" },
            separator_selected = { fg = "none", bg = "none" },
          },
        })
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
        vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none" })
        vim.api.nvim_set_hl(0, "BufferLineFill", { bg = "none" })
        vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
      '';
    })

    # cmp-cmdline
    (mkPlugin {
      owner = "hrsh7th";
      repo = "cmp-cmdline";
      rev = "d126061b624e0af6c3a556428712dd4d4194ec6d";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # cmp-nvim-lsp
    (mkPlugin {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "cbc7b02bb99fae35cb42f514762b89b5126651ef";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # cmp-path
    (mkPlugin {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "c642487086dbd9a93160e1679a1327be111cbc25";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # cmp_luasnip
    (mkPlugin {
      owner = "saadparwaiz1";
      repo = "cmp_luasnip";
      rev = "98d9cb5c2c38532bd9bdb481067b20fea8f32e90";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # conform.nvim
    (mkPlugin {
      owner = "stevearc";
      repo = "conform.nvim";
      rev = "1bf8b5b9caee51507aa51eaed3da5b0f2595c6b9";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      opts = {
        formatters_by_ft = {
          astro = [ "prettierd" ];
          css = [ "prettierd" ];
          html = [ "prettierd" ];
          templ = [ "prettierd" ];
          javascript = [ "prettierd" ];
          javascriptreact = [ "prettierd" ];
          typescript = [ "prettierd" ];
          typescriptreact = [ "prettierd" ];
          tsx = [ "prettierd" ];
          json = [ "prettierd" ];
          jsonc = [ "prettierd" ];
          lua = [ "stylua" ];
          mdx = [ "prettierd" ];
          nix = [ "nixfmt" ];
          python = [ "isort" "black" ];
          rust = [ "rustfmt" ];
          svelte = [ "prettierd" ];
          verilog = [ "verible" ];
          typst = [ "typstyle" ];
          yaml = [ "prettierd" ];
        };
        format_after_save = {
          lsp_fallback = true;
          quiet = true;
        };
        formatters = {
          gdformat = {
            command = "gdformat";
            args = "$FILENAME";
            stdin = false;
          };
          verible = {
            command = "verible-verilog-format";
            prepend_args = [ "--indentation_spaces" "4" ];
          };
        };
      };
    })

    # langmapper.nvim
    (mkPlugin {
      owner = "Wansmer";
      repo = "langmapper.nvim";
      rev = "57a2fe4d706676aa0386825f27c27a4e3c14e0b0";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      lazy = false;
      priority = 1;
      config = '' require('langmapper').setup() '';
    })

    # lspkind.nvim
    (mkPlugin {
      owner = "onsails";
      repo = "lspkind.nvim";
      rev = "3ddd1b4edefa425fda5a9f95a4f25578727c0bb3";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # lspsaga.nvim
    (mkPlugin {
      owner = "glepnir";
      repo = "lspsaga.nvim";
      rev = "8efe00d6aed9db6449969f889170f1a7e43101a1";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      event = "LspAttach";
      config = '' require("lspsaga").setup({}) '';
    })

    # lualine.nvim
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

    # mason.nvim
    (mkPlugin {
      owner = "williamboman";
      repo = "mason.nvim";
      rev = "57e5a8addb8c71fb063ee4acda466c7cf6ad2800";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      cmd = [ "Mason" "MasonInstall" "MasonUpdate" ];
      build = ":MasonUpdate";
      config = true; # This means it will be configured by home-manager's mason options
    })

    # mason-lspconfig.nvim
    (mkPlugin {
      owner = "williamboman";
      repo = "mason-lspconfig.nvim";
      rev = "b1d9a914b02ba5660f1e272a03314b31d4576fe2";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      config = ''
        require("mason-lspconfig").setup({
          ensure_installed = {
            "lua_ls", "pyright", "rust_analyzer", "clangd", "html", "cssls",
            "tailwindcss", "jsonls", "bashls", "tsserver", "emmet_ls", "marksman",
          },
          automatic_installation = true,
        })
      '';
    })

    # mason-tool-installer.nvim
    (mkPlugin {
      owner = "WhoIsSethDaniel";
      repo = "mason-tool-installer.nvim";
      rev = "517ef5994ef9d6b738322664d5fdd948f0fdeb46";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      config = ''
        require("mason-tool-installer").setup({
          ensure_installed = {
            "black", "isort", "flake8", "eslint_d", "prettierd", "stylua",
            "rustfmt", "nixfmt",
          },
          auto_update = true,
          run_on_start = true,
        })
      '';
    })

    # noice.nvim
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

    # nui.nvim (dependency of noice.nvim)
    (mkPlugin {
      owner = "MunifTanjim";
      repo = "nui.nvim";
      rev = "de740991c12411b663994b2860f1a4fd0937c130";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # nvim-autopairs
    (mkPlugin {
      owner = "windwp";
      repo = "nvim-autopairs";
      rev = "7a2c97cccd60abc559344042fefb1d5a85b3e33b";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      event = "InsertEnter";
      config = ''
        local npairs = require("nvim-autopairs")
        npairs.setup({
          check_ts = true,
          ts_config = {
            lua = { "string" },
            javascript = { "template_string" },
            java = false,
          },
          disable_filetype = { "TelescopePrompt", "vim" },
          fast_wrap = {
            map = "<M-e>",
            chars = { "{", "[", "(", '"', "'" },
            pattern = [=[[%'%"%)%>%]%)%}%,]]=],
            offset = 0,
            end_key = "$",
            keys = "qwertyuiopzxcvbnmasdfghjkl",
            check_comma = true,
            highlight = "PmenuSel",
            highlight_grey = "LineNr",
          },
        })
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        npairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))
      '';
    })

    # nvim-cmp
    (mkPlugin {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "d97d85e01339f01b842e6ec1502f639b080cb0fc";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      lazy = false;
      config = ''
        local cmp = require("cmp")
        local ls = require("luasnip")
        local lspkind = require("lspkind")
        require("luasnip.loaders.from_snipmate").lazy_load({
          paths = { "~/.config/home-manager/src/nvim/snippets" },
        })
        local has_words_before = function()
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0
            and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end
        cmp.setup({
          snippet = {
            expand = function(args)
              ls.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-j>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif ls.expand_or_jumpable() then
                ls.expand_or_jump()
              else
                cmp.complete()
              end
            end, { "i", "s" }),
            ["<C-k>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif ls.jumpable(-1) then
                ls.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.confirm({ select = true })
              elseif ls.expand_or_jumpable() then
                ls.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<C-Tab>"] = cmp.mapping(function()
              local suggestion = require("supermaven-nvim.completion_preview")
              if suggestion.has_suggestion() then
                suggestion.on_accept_suggestion()
              end
            end, { "i" }),
          }),
          sources = {
            { name = "supermaven" },
            { name = "nvim_lsp" },
            { name = "luasnip" },
          },
          formatting = {
            format = lspkind.cmp_format({
              mode = "symbol_text",
              maxwidth = 40,
              ellipsis_char = "...",
              symbol_map = { Supermaven = "⚡" },
              before = function(entry, vim_item)
                vim_item.kind = vim_item.kind .. " "
                return vim_item
              end,
            }),
          },
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
          experimental = { ghost_text = { hl_group = "CmpGhostText" } },
        })
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = "path" },
          }, {
            { name = "cmdline" },
          }),
        })
        require("supermaven-nvim").setup({
          disable_keymaps = true,
          disable_inline_suggestion = false,
          disable_suggestion_status = true,
        })
        vim.api.nvim_set_hl(0, "CmpGhostText", { fg = "#F77248", italic = true })
      '';
    })

    # nvim-colorizer.lua
    (mkPlugin {
      owner = "catgoose";
      repo = "nvim-colorizer.lua";
      rev = "81e676d3203c9eb6e4c0ccf1eba1679296ef923f";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      event = "BufReadPre";
      opts = {
        filetypes = { "*" };
        user_default_options = {
          RGB = true;
          RRGGBB = true;
          names = false;
          RRGGBBAA = true;
          AARRGGBB = true;
          rgb_fn = true;
          hsl_fn = true;
          css = false;
          css_fn = false;
          mode = "virtualtext";
          virtualtext_inline = true;
          tailwind = false;
          sass = { enable = false; parsers = [ "css" ]; };
          virtualtext = "▌";
          always_update = false;
        };
        buftypes = {};
      };
    })

    # nvim-lint
    (mkPlugin {
      owner = "mfussenegger";
      repo = "nvim-lint";
      rev = "baf7c91c2b868b12446df511d4cdddc98e9bf66e";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      config = ''
        local lint = require("lint")
        local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
        vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
        lint.linters_by_ft = {
          astro = { "eslint_d" };
          javascript = { "eslint_d" };
          svelte = { "eslint_d" };
          typescript = { "eslint_d" };
          typescriptreact = { "eslint_d" };
          html = { "eslint_d" };
          templ = { "eslint_d" };
          tsx = { "eslint_d" };
          python = { "flake8" };
        }
        local function safe_lint()
          local ok = pcall(lint.try_lint)
          if not ok then
            vim.schedule(function()
              vim.api.nvim_echo({
                { "⚠ lint skipped (tool not found)", "WarningMsg" },
              }, false, {})
            end)
          end
        end
        vim.api.nvim_create_autocmd({ "BufWritePost" }, {
          callback = function()
            safe_lint()
          end,
        })
      '';
    })

    # nvim-lspconfig
    (mkPlugin {
      owner = "neovim";
      repo = "nvim-lspconfig";
      rev = "d4f77e7a9a4b910622a0bc225e482c4c808e4099";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      event = [ "BufReadPre" "BufNewFile" ];
      config = ''
        local lspconfig = require("lspconfig")
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok then
          capabilities = cmp_lsp.default_capabilities(capabilities)
        end
        local on_attach = function(client, bufnr)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end
          map("n", "<leader>th", function()
            for _, c in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
              if c.supports_method("textDocument/inlayHint") then
                local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
              end
            end
          end, "Toggle Inlay Hints")
          if client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end
        local map = vim.keymap.set
        map("n", "gh", "<cmd>Lspsaga hover_doc<CR>", { desc = "Lspsaga Hover" })
        map("n", "gr", "<cmd>Lspsaga lsp_finder<CR>", { desc = "Lspsaga References" })
        map("n", "gd", "<cmd>Lspsaga goto_definition<CR>", { desc = "Lspsaga Definition" })
        map("n", "gD", "<cmd>Lspsaga peek_definition<CR>", { desc = "Lspsaga Peek Definition" })
        map("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Lspsaga Rename" })
        map("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Lspsaga Code Action" })
        map("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line Diagnostics" })
        map("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { desc = "Cursor Diagnostics" })
        map("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Prev Diagnostic" })
        map("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next Diagnostic" })
        map("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { desc = "Toggle Outline" })
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
        vim.diagnostic.config({
          virtual_text = { prefix = "●" },
          signs = true,
          update_in_insert = true,
          underline = true,
          severity_sort = true,
          float = { border = "rounded", source = "always" },
        })
        local servers = {
          lua_ls = {
            settings = {
              Lua = {
                hint = {
                  enable = true; arrayIndex = true; setType = true; paramName = true;
                  paramType = true; returnType = true;
                };
                diagnostics = { globals = { "vim" } };
                workspace = { checkThirdParty = false };
                telemetry = { enable = false };
              };
            };
          };
          pyright = {
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true; useLibraryCodeForTypes = true;
                  diagnosticMode = "openFilesOnly";
                };
              };
            };
          };
          rust_analyzer = {
            settings = {
              ["rust-analyzer"] = {
                cargo = { allFeatures = true };
                checkOnSave = { command = "clippy" };
              };
            };
          };
          clangd = {
            cmd = [ "clangd" "--background-index" "--clang-tidy" ];
            filetypes = [ "c" "cpp" "objc" "objcpp" ];
          };
          html = {}; cssls = {}; tailwindcss = {}; jsonls = {}; bashls = {};
          tsserver = {
            settings = {
              javascript = { suggest = { autoImports = true }; format = { enable = true }; };
              typescript = { suggest = { autoImports = true }; format = { enable = true }; };
            };
          };
          emmet_ls = {
            filetypes = [ "html" "css" "typescriptreact" "javascriptreact" ];
          };
          marksman = {};
        }
        for name, opts in pairs(servers) do
          opts.capabilities = capabilities
          opts.on_attach = on_attach
          lspconfig[name].setup(opts)
        end
      '';
    })

    # nvim-treesitter
    (mkPlugin {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "42fc28ba918343ebfd5565147a42a26580579482";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      build = ":TSUpdate";
      config = ''
        require('nvim-treesitter.configs').setup {
          ensure_installed = {
            'lua','vim','query',
            'bash','json','yaml','toml','markdown','regex',
            'c','cpp','python',
            'javascript','typescript','html','css',
            'rust',
          },
          highlight = { enable = true },
        }
      '';
    })

    # nvim-ts-context-commentstring (dependency of Comment.nvim)
    (mkPlugin {
      owner = "JoosepAlviste";
      repo = "nvim-ts-context-commentstring";
      rev = "1b212c2eee76d787bbea6aa5e92a2b534e7b4f8f";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # nvim-web-devicons
    (mkPlugin {
      owner = "nvim-tree";
      repo = "nvim-web-devicons";
      rev = "8dcb311b0c92d460fac00eac706abd43d94d68af";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # plenary.nvim (dependency of telescope.nvim)
    (mkPlugin {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "b9fd5226c2f76c951fc8ed5923d85e4de065e509";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # supermaven-nvim
    (mkPlugin {
      owner = "supermaven-inc";
      repo = "supermaven-nvim";
      rev = "07d20fce48a5629686aefb0a7cd4b25e33947d50";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # telescope-fzf-native.nvim
    (mkPlugin {
      owner = "nvim-telescope";
      repo = "telescope-fzf-native.nvim";
      rev = "6fea601bd2b694c6f2ae08a6c6fab14930c60e2c";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release";
    })

    # telescope-themes
    (mkPlugin {
      owner = "andrew-george";
      repo = "telescope-themes";
      rev = "65721365bd7a04a6c9679e76b6387b60320fd5f3";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # telescope-zoxide
    (mkPlugin {
      owner = "jvgrootveld";
      repo = "telescope-zoxide";
      rev = "54bfe630bad08dc9891ec78c7cf8db38dd725c97";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    })

    # telescope.nvim
    (mkPlugin {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "a0bbec21143c7bc5f8bb02e0005fa0b982edc026";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      branch = "0.1.x";
      config = ''
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")
        telescope.load_extension("themes")
        telescope.load_extension("zoxide")
        telescope.load_extension("fzf")
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
        vim.keymap.set("n", "<leader>thm", function() telescope.extensions.themes.themes() end, { desc = "Theme Switcher" })
        vim.keymap.set("n", "<leader>z", function() telescope.extensions.zoxide.list() end, { desc = "Zoxide list" })
      '';
    })

    # yazi.nvim
    (mkPlugin {
      owner = "mikavilpas";
      repo = "yazi.nvim";
      rev = "56a8c4de40cf2d40bcab93ff45e24beff81332e6";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
      event = "VeryLazy";
      config = ''
        require("yazi").setup({
          open_for_directories = true,
          keymaps = {
            show_help = "<F1>",
          },
        })
      '';
      extraLua = ''
        vim.keymap.set("n", "<Right>", "<cmd>Yazi<CR>", { desc = "Open Yazi in current file's directory" })
        vim.keymap.set("n", "<leader>y", "<cmd>Yazi cwd<CR>", { desc = "Open Yazi in working directory" })
        vim.keymap.set("n", "<leader>r", "<cmd>Yazi toggle<CR>", { desc = "Resume last Yazi session" })
        vim.keymap.set("n", "q", "<cmd>Yazi close<CR>", { desc = "Close Yazi" })
      '';
    })
  ];

in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Global Neovim options from config/options.lua
    settings = {
      number = true;
      relativenumber = true;
      cursorline = true;
      cursorcolumn = false;
      signcolumn = "yes";
      expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
      smartindent = true;
      autoindent = true;
      termguicolors = true;
      background = "dark";
      clipboard = "unnamedplus";
      undofile = true;
      ignorecase = true;
      smartcase = true;
      swapfile = true;
      backup = true;
      wrap = false;
      scrolloff = 8;
      sidescrolloff = 8;
      splitright = true;
      splitbelow = true;
      mouse = "a";
      backspace = "start,eol,indent";
      hlsearch = true;
      incsearch = true;
      inccommand = "split";
      wildmenu = true;
      wildmode = "longest:full,full";
    };

    # Custom Lua for global keymaps and autocommands
    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Global Keymaps from config/keymaps.lua
      local opts = { noremap = true, silent = true }
      local keymap = vim.keymap

      vim.api.nvim_set_keymap("n", "j", "k", opts)
      vim.api.nvim_set_keymap("n", "k", "j", opts)
      vim.api.nvim_set_keymap("n", "l", "h", opts)
      vim.api.nvim_set_keymap("n", ";", "l", opts)
      vim.api.nvim_set_keymap("v", "j", "k", opts)
      vim.api.nvim_set_keymap("v", "k", "j", opts)
      vim.api.nvim_set_keymap("v", "l", "h", opts)
      vim.api.nvim_set_keymap("v", ";", "l", opts)
      vim.api.nvim_set_keymap("", "<C-s>", "<cmd>w<CR>", opts)
      vim.api.nvim_set_keymap("n", "/", ":", { noremap = true, silent = false })
      vim.api.nvim_set_keymap("v", "/", ":", { noremap = true, silent = false })
      vim.keymap.set("n", "=", "<C-a>", { noremap = true, silent = true })
      vim.keymap.set("n", "-", "<C-x>", { noremap = true, silent = true })
      vim.keymap.set("n", "dw", 'vb"_d')
      vim.keymap.set("n", "<C-a>", "gg<S-v>G")
      vim.keymap.set("n", "cl", "Yp", opts)
      vim.keymap.set("v", "cl", "Yp", opts)
      vim.api.nvim_set_keymap("n", "sl", "^", opts)
      vim.api.nvim_set_keymap("n", "el", "$", opts)
      vim.api.nvim_set_keymap("v", "sl", "^", opts)
      vim.api.nvim_set_keymap("v", "el", "$", opts)
      vim.keymap.set("n", "<A-S-j>", ":m .-2<CR>==", { noremap = true, silent = true })
      vim.keymap.set("n", "<A-S-k>", ":m .+1<CR>==", { noremap = true, silent = true })
      vim.keymap.set("v", "<A-S-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
      vim.keymap.set("v", "<A-S-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
      vim.keymap.set("n", "nw", "w", { noremap = true, silent = true })
      vim.keymap.set("n", "bw", "b", { noremap = true, silent = true })
      vim.keymap.set("n", "f(", "f(l", { noremap = true, silent = true })
      vim.keymap.set("n", "f]", "f[l", { noremap = true, silent = true })
      vim.keymap.set("n", "f}", "f{l", { noremap = true, silent = true })
      vim.keymap.set("v", "<", "<gv", opts)
      vim.keymap.set("v", ">", ">gv", opts)
      vim.keymap.set("n", ".", "/", { noremap = true })
      vim.keymap.set("n", ",", "?", { noremap = true })
      vim.keymap.set("n", "m", "nzzzv")
      vim.keymap.set("n", "M", "Nzzzv")
      vim.keymap.set("i", "<C-m>", "<Esc>")
      vim.keymap.set("n", "<C-m>", ":nohl<CR>", { desc = "Clear search hl", silent = true })
      vim.keymap.set("n", "<Leader>j", ":bprevious<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>k", ":bnext<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>q", ":bdelete<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>lw", "<cmd>set wrap!<CR>", opts)

      local function smart_word_select()
        local mode = vim.fn.mode()
        if mode == "n" then
          vim.api.nvim_feedkeys("viw", "n", true)
        elseif mode == "v" then
          vim.api.nvim_feedkeys("w", "n", true)
        end
      end
      vim.keymap.set({ "n", "v" }, "sw", smart_word_select, { noremap = true, silent = true, desc = "Инкрементальное выделение слов" })

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
      vim.keymap.set("n", "<leader>ra", function() InteractiveReplace("all") end, { noremap = true, silent = true, desc = "Заменить все вхождения последнего поиска" })
      vim.keymap.set("n", "<leader>rl", function() InteractiveReplace("line") end, { noremap = true, silent = true, desc = "Заменить на текущей строке" })

      -- Autocommands from config/autocmds.lua
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.lua",
        callback = function()
          local file = vim.fn.expand("<afile>")
          if file:match("init.lua") or file:match("lua/config/") then
            vim.cmd("silent source " .. file)
          end
        end,
      })

      -- Swap/Undo/Backup directories (from config/options.lua)
      local data_path = vim.fn.stdpath("data")
      for _, dir in ipairs({ "swap", "undo", "backup" }) do
        local path = data_path .. "/" .. dir
        if vim.fn.isdirectory(path) == 0 then
          vim.fn.mkdir(path, "p")
        end
      end
      vim.opt.directory = data_path .. "/swap//"
      vim.opt.backupdir = data_path .. "/backup//"
      vim.opt.undodir = data_path .. "/undo//"

      -- Colorscheme from init.lua
      vim.cmd("colorscheme artgreendream")
    '';

    # Plugins
    plugins = pluginsList;

    # Ensure external tools are available
    # Note: Some of these might be redundant if already in home.packages
    # but it's safer to list them here for Neovim's context.
    extraPackages = with pkgs; [
      # For LSP servers and formatters/linters
      lua-language-server
      python3Packages.pyright
      rust-analyzer
      clang-tools
      nodePackages.vscode-html-languageserver
      nodePackages.vscode-css-languageserver
      nodePackages.tailwindcss-language-server
      nodePackages.vscode-json-languageserver
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      nodePackages.emmet-language-server
      marksman
      black
      isort
      flake8
      nodePackages.eslint_d
      nodePackages.prettierd
      stylua
      rustfmt
      nixfmt
      gdformat
      verible
      typst
      # Other tools
      yazi
      cmake # For telescope-fzf-native.nvim
    ];
  };

  # Ensure yazi and cmake are available in the user's path
  home.packages = with pkgs; [
    yazi
    cmake
  ];
}