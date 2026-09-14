# home/features/development/default.nix — языки, LSP, gamedev, API/DB
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # ── Языки и LSP (из artlaus/features/cli/default.nix) ──
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

    # ── Gamedev (из system/packages.legacy) ──
    godot
    gdtoolkit_4
    ldtk

    # ── API / DB ──
    dbeaver-bin
    pgadmin4
    postman
    insomnia

    # ── Diagram / docs (dev-related) ──
    drawio
    xournalpp
    hugo
  ];
}
