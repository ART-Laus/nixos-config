# system/packages.nix — остаток системных пакетов (после выноса в модули)
# Мигрировано: fonts → system/nix.nix, polkit/gvfs/ollama → services.nix, steam/gamemode → gaming.nix
# Остальное — то, что пока не раскладывается, постепенно переедет в home/features/*
{ pkgs, ... }:
{
  # Fonts — оставлены здесь до выноса в system/nix.nix (или отдельный fonts.nix)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
    nerd-fonts.caskaydia-mono
    carlito
    terminus_font
    inconsolata
    font-awesome
    liberation_ttf
    dejavu_fonts
    cantarell-fonts
    unifont
    unifont_upper
  ];

  # Минимальный набор системных пакетов — всё остальное в home/features/*
  environment.systemPackages = with pkgs; [
    # Core CLI (должны быть доступны до home)
    git
    curl
    wget
    htop

    # File managers (системная часть — thunar уже в services.nix)
    # Остальное переедет в home

    # Hardware utils
    pciutils
    usbutils
    lm_sensors

    # Fonts / icons (системные)
    adwaita-icon-theme
    papirus-icon-theme
  ];
}
