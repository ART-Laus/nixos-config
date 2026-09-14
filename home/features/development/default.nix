# home/features/development/default.nix — языки, LSP, devShells
{ config, pkgs, lib, ... }:
{
  # Пока stub — языки вынесены из artlaus/features/cli/default.nix
  # После миграции: python, rust, go, node, lua, nixd, etc. через devShells + direnv
  home.packages = with pkgs; [
    # Python
    python3Full
    pyright
    ruff
    # Nix
    nixd
    nixpkgs-fmt
    nil
    # Lua
    lua-language-server
    stylua
    # Rust
    rust-analyzer
    # Go
    gopls
    golangci-lint
    # Frontend
    typescript-language-server
    tailwindcss-language-server
    vscode-langservers-extracted
    # Shell
    bash-language-server
    shellcheck
    shfmt
    # SQL
    # sqls — если нужен
  ];
}
