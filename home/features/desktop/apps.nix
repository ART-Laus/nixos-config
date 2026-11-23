# home/features/desktop/apps.nix — файловый менеджер, утилиты, системные GUI-приложения
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # ── Файловый менеджер: Dolphin (Thunar/Xfce удалён полностью) ──
    # ranger удалён — заменён на yazi (home/features/cli/yazi.nix)
    kdePackages.dolphin
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

  # Каталог открывается в Dolphin везде (xdg-open, файл-пикеры, рабочий стол)
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "org.kde.dolphin.desktop";
    "x-directory/normal" = "org.kde.dolphin.desktop";
  };
}
