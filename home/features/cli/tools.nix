# home/features/cli/tools.nix — CLI утилиты (eza, bat, ripgrep, fd, fzf, btop...)
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
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
