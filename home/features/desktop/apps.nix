# home/features/desktop/apps.nix — файловые менеджеры, утилиты, системные GUI-приложения
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # ── Файловые менеджеры и тумбнейлы (из legacy) ──
    # ranger удалён — заменён на yazi (home/features/cli/yazi.nix)
    xfce.thunar
    xfce.catfish
    xfce.exo
    file-roller
    ffmpegthumbnailer
    gnome-epub-thumbnailer
    f3d
    openscad

    # ── Поддержка форматов (были в system, теперь home) ──
    # Оставлены только GUI-тулы; библиотеки — в system/packages.nix

    # ── Системные GUI утилиты ──
    networkmanagerapplet
    brightnessctl
    qmk
    vial

    # ── Соцсети ──
    discord
    ayugram-desktop
  ];
}
