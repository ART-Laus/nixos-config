{ config, pkgs, lib, ... }:

let cfg = config.artlaus.cli;
in {
  options.artlaus.cli = {
    enable = lib.mkEnableOption "CLI features and tools";
  };

  config = lib.mkIf cfg.enable {
    # Импортируем конфигурацию Starship
    imports = [
      ./starship/starship.nix
      ./git/git.nix
      ./zsh/zsh.nix
      ./alacritty/alacritty.nix
      ./wezterm/wezterm.nix
      ./yazi/yazi.nix
      ./tmux/tmux.nix
      ./nvim/default.nix
      ./neofetch/default.nix # Corrected path
    ];

    # All CLI tools are now managed in this module
    home.packages = with pkgs; [
      # --- Terminals ---
      alacritty
      kitty

      # --- Shells ---
      pkgs2.nushell
      
      # --- Existing Core Utilities ---
      exa
      yq
      ncdu
      dog
      mtr
      entr
      tldr
      chafa
      pywal
      
      # --- Programming Languages, LSPs, and Compilers ---
      # Python
      python3Full
      python3Packages.pip
      python3Packages.debugpy
      pyright
      ruff
      # C/C++
      clang-tools
      ccls
      clang
      gcc
      glibc
      gnumake
      cmake-language-server
      cmake
      # Rust
      rustup
      rust-analyzer
      # Go
      go
      gopls
      delve
      templ
      golangci-lint
      # Nix
      nixd
      # Lua
      lua5_1
      luajit
      luajitPackages.luarocks
      lua-language-server
      stylua
      # Shell/Bash
      bash-language-server
      shellcheck
      shfmt
      # SQL
      sqls
      postgres-lsp
      sqlite
      # Frontend
      pkgs2.nodejs_24
      htmx-lsp
      emmet-language-server
      vscode-langservers-extracted
      typescript-language-server
      tailwindcss-language-server
      svelte-language-server
      # Protobuf
      protols
      protobuf
      protoc-gen-go
      protoc-gen-go-grpc
      # Other
      hugo
      yaml-language-server
      taplo
      vim-language-server
      go-migrate
      neovim

      # --- Core CLI tools ---
      openssl
      wget
      curl
      git
      gnutar
      gnugrep
      gawk
      rsync
      bat
      htop
      lazygit
      zoxide
      fzf
      ripgrep
      fd
      jq
      httpie
      tree
      killall
      pass
      timer
      fastfetch
      pwgen
      lm_sensors
      miller
      usbutils
      
      # --- Archives ---
      zip
      unzip
      unrar
      p7zip
      bzip2

      # --- Media & Image CLI tools ---
      ffmpeg_7
      svt-av1
      imagemagick
      vips
      pkgs2.yt-dlp
      pkgs2.gallery-dl
      
      # --- Parsers & System tools ---
      tree-sitter
      libxml2
      f2fs-tools
      exfat
      libqalculate

      # --- ROCm/GPU CLI tools ---
      amdgpu_top
      rocmPackages.rocm-smi
      rocmPackages.rocblas
      rocmPackages.hipblas
      rocmPackages.clr
    ];

    # Включаем модули home-manager для некоторых CLI-инструментов
    programs = {
      # zoxide для умного перехода по директориям
      zoxide = {
        enable = true;
        enableZshIntegration = true; # Предполагаем интеграцию с zsh
      };

      # fzf для интерактивного поиска
      fzf = {
        enable = true;
        enableZshIntegration = true; # Предполагаем интеграцию с zsh
        # Дополнительные настройки fzf могут быть добавлены здесь
      };

      # bat в качестве cat с подсветкой синтаксиса
      bat = {
        enable = true;
        # Можно добавить дополнительные настройки, например, темы
        # themes = [ "TwoDark" ];
      };

      # fd в качестве альтернативы find
      # В home-manager нет специальной программы, но пакет включен выше

      # ripgrep - быстрый grep. Пакет включен выше.

      # lazygit - консольный интерфейс для git
      # В home-manager нет специальной программы, но пакет включен выше.
    };

    # TODO: Добавить другие настройки для CLI, такие как переменные окружения, алиасы, etc.
  };
}
