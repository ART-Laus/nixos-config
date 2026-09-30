# home/features/development/default.nix — языки, LSP, API/DB
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # ── Языки и LSP ──
    # Python (26.05: python3Full удалён, всё включено в python3)
    python3
    pyright
    ruff
    # Nix
    nixd
    nixpkgs-fmt
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

    # ── API / DB ──
    dbeaver-bin
    pgadmin4
    postman
    insomnia

    # ── Диаграммы / документы / заметки ──
    drawio
    xournalpp
    hugo
  ];
}
