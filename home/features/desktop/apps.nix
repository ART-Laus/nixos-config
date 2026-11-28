# home/features/desktop/apps.nix — файловый менеджер, утилиты, системные GUI-приложения
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # ── Файловый менеджер: Thunar ставится системным модулем programs.thunar ──
    # ranger удалён — заменён на yazi (home/features/cli/yazi.nix)
    catfish
    file-roller
    ffmpegthumbnailer
    gnome-epub-thumbnailer
    f3d
    openscad

    # ── Поддержка форматов (были в system, теперь home) ──
    # Оставлены только GUI-тулы; библиотеки — в system/packages.nix

    # ── Системные GUI утилиты ──
    podman-desktop
    networkmanagerapplet
    brightnessctl
    qmk
    vial
    simple-scan

    # ── Соцсети ──
    discord
    ayugram-desktop
  ];
}
