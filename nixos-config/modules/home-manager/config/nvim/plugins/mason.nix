{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

[
  (mkPlugin {
    owner = "williamboman";
    repo = "mason.nvim";
    rev = "57e5a8addb8c71fb063ee4acda466c7cf6ad2800";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder
    cmd = [ "Mason" "MasonInstall" "MasonUpdate" ];
    build = ":MasonUpdate";
    config = true; # This means it will be configured by home-manager's mason options
  })

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
]
