{
  home.file.".config/nvim/lua/plugins/lsp.lua".text = ''
    return {
      "neovim/nvim-lspconfig",
      dependencies = { "nvim-telescope/telescope.nvim" }, -- Assuming lspsaga-nvim is loaded elsewhere, and telescope for lsp_finder
      config = function()
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
                runtime = { version = "LuaJIT" },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                diagnostics = { globals = { "vim" } },
                telemetry = { enable = false },
              },
            },
          },
          pyright = {
            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  diagnosticMode = "openFilesOnly",
                },
              },
            },
          },
          rust_analyzer = {
            settings = {
              ["rust-analyzer"] = {
                cargo = { allFeatures = true },
                checkOnSave = { command = "clippy" },
              },
            },
          },
          clangd = {
            cmd = { "clangd", "--background-index", "--clang-tidy" },
            filetypes = { "c", "cpp", "objc", "objcpp" },
          },
          html = {},
          cssls = {},
          tailwindcss = {},
          jsonls = {},
          bashls = {},
          ts_ls = {
            settings = {
              javascript = {
                suggest = { autoImports = true },
                format = { enable = true },
              },
              typescript = {
                suggest = { autoImports = true },
                format = { enable = true },
              },
            },
          },
          emmet_ls = {
            filetypes = { "html", "css", "typescriptreact", "javascriptreact" },
          },
          marksman = {},
        }

        for name, opts in pairs(servers) do
          local final_opts = vim.tbl_deep_extend("force", {
            on_attach = on_attach,
            capabilities = capabilities,
          }, opts or {})
          vim.lsp.config(name, final_opts)
        end
        vim.lsp.enable(vim.tbl_keys(servers))
      end
    }
  '';
}