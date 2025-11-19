{ config, pkgs, mkPlugin, mkBuiltinPlugin, ... }:

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
