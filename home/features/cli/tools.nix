# home/features/cli/tools.nix — CLI утилиты (eza, bat, ripgrep, fd, fzf, btop...)
{ config, pkgs, lib, flakePkgs, ... }:
let
  c = config.lib.theme.colors or {};
  automationScripts = builtins.attrValues (import ../../../scripts { inherit pkgs; });
in
{
  home.packages = automationScripts ++ (with pkgs; [
    # Modern replacements (было: exa → eza)
    eza
    bat
    ripgrep
    fd
    fzf
    zoxide
    btop
    jq
    yq
    ncdu
    dog
    mtr
    entr
    tldr
    chafa
    # pywal — оставить пока, но тема теперь из theme/
    # pywal

     # Archives
     zip
     unzip
     unrar
     p7zip
     bzip2

     # PDF CLI
     poppler-utils

     # OCR
     tesseract
     ocrmypdf

     # Image optimization
     optipng
     pngquant
     jpegoptim
     gifsicle

     # Documents
     pandoc

    # Batch rename / duplicates
    rename
    fdupes

    # QR
    qrencode

    # Nix UX
    nh
    nvd
    nixpkgs-fmt

    # Python for share script (26.05: python3Full удалён, tkinter в python3 по умолчанию)
    python3

    # Hash / file info
    file
    hashid

    # Clipboard
    wl-clipboard


    # Media CLI
    ffmpeg_7
    imagemagick
    vips

    # Parsers & System
    tree-sitter
    libxml2
    f2fs-tools
    exfat
    libqalculate

    # Git tools (дополняют programs.git)
    lazygit
    gh
    git-lfs
    delta

    # AI CLI tools (устанавливаются через npm: npm install -g opencode @anthropic-ai/claude-code lilo-code)
    # opencode — AI code editor
    # claude-code — Anthropic Claude CLI
    # lilo-code — AI coding assistant

    # Security / misc
    pass
    pwgen
    lm_sensors
    usbutils
    miller
    tree
    killall
    timer
    file
    hashid
    wl-clipboard

    # ── Discovery Expansion — 🎨 Визуал / ASCII / Терминальная Графика ──
    # anima — набор терминальных анимаций (boids, matrix, mandelbrot)
    flakePkgs.anima

    # ── Discovery Expansion — 🖼 Изображения / Медиа CLI ──
    # timg — терминальный просмотрщик изображений и видео
    timg
    # notcurses — библиотека character graphics + встроенные инструменты
    notcurses

    # ── Discovery Expansion — 🧬 Nix / System Internals ──
    flakePkgs.nixard
    flakePkgs.verynix
    flakePkgs.super-comma
    flakePkgs.nixy
    flakePkgs.niux

    # Nix UX wrappers
    nh
    nvd
    nixpkgs-fmt

    # ── Discovery Expansion — 🎲 Fun ──
    # nix-bonsai — бонсай-деревогенератор на чистом Nix
    flakePkgs.nix-bonsai


  ]);

  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    bat.enable = true;
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
