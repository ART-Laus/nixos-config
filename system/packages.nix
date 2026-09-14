# This file contains system-wide packages, fonts, and services.
# CLI tools and WM-specific packages have been removed to be managed in their respective modules.
{ pkgs, pkgs2, spkgs, inputs, ... }: {

  # https://nixos.wiki/wiki/Fonts
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

  systemd = { # Polkit agent for root access GUI prompts
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };

  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities for Thunar file manager
    tumbler.enable = true; # Thumbnail support for Thunar file manager
    ollama = {
      enable = true;
      acceleration = "rocm";
      host = "0.0.0.0";
      port = 11434;
      openFirewall = true;
      package = pkgs2.ollama;
      rocmOverrideGfx = "10.3.0"; 
    };
  };

  programs = {
    nix-ld = { # Compatibility layer for non-Nix binaries
      enable = true;
      libraries = with pkgs2; [
        stdenv.cc.cc
        kdePackages.qtbase
        kdePackages.qttools
        kdePackages.qtwayland
        kdePackages.qtsvg
        kdePackages.qtimageformats
        util-linux
        zlib
        zstd
        mesa
        libGL
        libglvnd
        libxkbcommon
        freetype
        fontconfig
        xorg.libX11
        xorg.libXext
        xorg.libXrandr
        xorg.libXrender
        xorg.libXcursor
        xorg.libXxf86vm
        xorg.libXi
        xorg.libxcb
        xorg.libXfixes
        xorg.xcbutil
        xorg.xcbutilkeysyms
        xorg.xcbutilwm
        xorg.xcbutilimage
        xorg.xcbutilrenderutil
        xcb-util-cursor
        glib
        dbus
        krb5
      ];
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };

    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: with pkgs; [ libpng libpng12 libepoxy pcre2 double-conversion ];
      };
    };

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-media-tags-plugin
        thunar-archive-plugin
        thunar-volman
      ];
    };
    xfconf.enable = true; # For Thunar configs

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    gamemode.enable = true;
    gamescope.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Gamedev
    pkgs2.godot
    pkgs2.gdtoolkit_4
    ldtk

    # API / DB
    dbeaver-bin
    pgadmin4
    postman
    insomnia
    
    # GUI Apps
    ksnip
    file-roller
    qbittorrent
    thunderbird
    screenkey
    pavucontrol
    networkmanagerapplet
    brightnessctl

    # Browsers
    librewolf
    firefox
    chromium

    # Docs
    evince
    libreoffice
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
    spkgs.calibre
    drawio
    xournalpp

    # File managers & thumbnails
    ranger # Kept here as it's a GUI-like file manager
    xfce.thunar
    xfce.catfish
    xfce.exo
    ffmpegthumbnailer
    gnome-epub-thumbnailer
    f3d
    openscad

    # File support
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

    # Media
    strawberry
    obs-studio
    mpv
    imv
    qview
    feh

    # Social
    pkgs2.discord
    pkgs2.telegram-desktop

    # Games & Gaming Utilities
    protonup-qt
    steam-run
    pkgs2.mangohud
    pkgs2.wineWowPackages.stableFull
    pkgs2.winetricks

    # Design
    krita
    pkgs2.gimp3
    gcolor3

    # Productivity
    obsidian
    pkgs2.planify

    # Icons
    adwaita-icon-theme
    libsForQt5.breeze-icons
    kdePackages.breeze-icons
    papirus-icon-theme
    material-icons
    gruvbox-plus-icons

    # Vulkan
    gfxreconstruct
    glslang
    spirv-cross
    spirv-headers
    spirv-tools
    vulkan-extension-layer
    vulkan-headers
    vulkan-loader
    vulkan-tools
    vulkan-tools-lunarg
    vulkan-utility-libraries
    vulkan-validation-layers
    vkdisplayinfo
    vk-bootstrap
    dxvk
    vkd3d
    vkd3d-proton

    # Other System Utilities
    qmk
    vial
    fontconfig
    zlib
    libva-utils
    clinfo
    libsecret
    alsa-utils
    pamixer
    easyeffects
  ];
}
