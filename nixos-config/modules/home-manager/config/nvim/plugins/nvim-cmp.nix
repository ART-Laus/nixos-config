{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

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
