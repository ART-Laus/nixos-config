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

  environment.systemPackages = with pkgs; [
    # ── Core CLI ──
    git
    curl
    wget
    htop

    # ── Hardware utils ──
    pciutils
    usbutils
    lm_sensors
    libva-utils
    clinfo
    alsa-utils
    pamixer

    # ── Icons (системные, дополняют home/gtk-qt.nix) ──
    # Papirus-Dark — основной (используется в gtk.iconTheme)
    adwaita-icon-theme
    papirus-icon-theme
    kdePackages.breeze-icons

    # ── File support libs (нужны системе для тумбнейлов) ──
    kdePackages.kimageformats
    libsForQt5.kimageformats
    kdePackages.qtimageformats
    libsForQt5.qt5.qtimageformats
    kdePackages.qtsvg
    kdePackages.karchive
    webp-pixbuf-loader
    gdk-pixbuf.dev
    libwebp
    libavif
    libheif
    libgsf
    libjxl
    libraw
    librsvg
    jxrlib
    poppler
    freetype
    imath
    openexr
    fontconfig
    libsecret
    zlib
  ];
}
