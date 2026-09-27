# home/features/cli/tools.nix — CLI утилиты (eza, bat, ripgrep, fd, fzf, btop...)
{ config, pkgs, lib, flakePkgs, ... }:
let
  c = config.lib.theme.colors or {};
in
{
  home.packages = with pkgs; [
    (import ../../../../scripts { inherit pkgs; })
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
     tar
     zstd
     xz
     lzma

     # PDF CLI
     poppler_utils

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

    # Python for share script
    python3Full

    # Hash / file info
    file
    hashid

    # Clipboard
    wl-clipboard
    wl-copy
    wl-paste

    # Unicode / color
    unicode
    color

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
    wl-copy
    wl-paste
    unicode
    color

    # ── Discovery Expansion — 🎨 Визуал / ASCII / Терминальная Графика ──
    # px2ansi-rs — рендерер терминальных изображений (10 стилей, SIMD)
    (runCommand "px2ansi-rs" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out px2ansi-rs
    '')
    # vinz — 3D raymarching терминальный арт
    (runCommand "vinz" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out vinz
    '')
    # anima — набор терминальных анимаций (boids, matrix, mandelbrot)
    flakePkgs.anima

    # ── Discovery Expansion — 🖼 Изображения / Медиа CLI ──
    # timg — терминальный просмотрщик изображений и видео
    timg
    # notcurses — библиотека character graphics + встроенные инструменты
    notcurses

    # ── Discovery Expansion — 🖥 TUI ──
    # tuitab — TUI explorer для табличных данных
    (runCommand "tuitab" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out tuitab
    '')
    # tooi — терминальный Mastodon клиент
    (runCommand "tooi" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out tooi
    '')
    # bitchat-tui — зашифрованный P2P чат через Bluetooth
    (runCommand "bitchat-tui" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out bitchat-tui
    '')

    # ── Discovery Expansion — 📊 Визуализация Системы ──
    # puls — unified monitoring + system administration
    (runCommand "puls" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out puls
    '')

    # ── Discovery Expansion — 🧬 Nix / System Internals ──
    # nixmate — unified NixOS management TUI
    flakePkgs.nixmate
    # nixard — visual package closure analysis
    flakePkgs.nixard
    # verynix — запустить любую версию любого Nix пакета
    flakePkgs.verynix
    # super-comma — ultra-fast Nix runner
    flakePkgs.super-comma
    # nixy — simple Nix package manager (asdf/Homebrew alternative)
    flakePkgs.nixy
    # niux — declarative NixOS/home-manager CLI
    flakePkgs.niux
    # nix-pretty — переписывает nix store paths в читаемые пути
    (runCommand "nix-pretty" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out nix-pretty
    '')

    # Nix UX wrappers
    nh
    nvd
    nixpkgs-fmt

    # ── Discovery Expansion — ✍️ Текст / Unicode ──
    # coretilus — coreutils parody (sl, gti, mr)
    (runCommand "coretilus" { buildInputs = [ cargo rustc ]; } ''
      cargo install --root $out coretilus
    '')

    # ── Discovery Expansion — 🎲 Fun ──
    # nix-bonsai — бонсай-деревогенератор на чистом Nix
    flakePkgs.nix-bonsai

    # ── Discovery Expansion — npm-пакеты ──
    # phosphor — рендеринг изображений/PDF/Markdown в терминале
    (runCommand "phosphor" { buildInputs = [ pnpm ]; } ''
      mkdir -p $out/bin
      pnpm add --prefix $out phosphor
      ln -sf $out/node_modules/.bin/phosphor $out/bin/phosphor
    '')
    # milli — пиксельно-точная анимированная ASCII-art
    (runCommand "milli" { buildInputs = [ pnpm ]; } ''
      mkdir -p $out/bin
      pnpm add --prefix $out @amansingh-afk/milli
      ln -sf $out/node_modules/.bin/milli $out/bin/milli
    '')
  ];

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
