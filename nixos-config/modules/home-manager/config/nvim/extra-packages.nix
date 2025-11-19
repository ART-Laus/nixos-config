{ config, pkgs, ... }:

{
  programs.neovim.extraPackages = with pkgs; [
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
}
