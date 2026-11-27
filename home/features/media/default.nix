# home/features/media/default.nix — медиа, музыка, OBS, дизайн, продуктивность
{ config, pkgs, ... }:
{
  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    savePath=${config.home.homeDirectory}/Documents/Лайтшот/Скрины
    savePathFixed=false
    disabledTrayIcon=false
    showStartupLaunchMessage=false
    # Wayland (Hyprland): DBus-бэкенд зависает, используем grim-адаптер
    useGrimAdapter=true
    disabledGrimWarning=true
    # Явно задаём расширение: иначе flameshot берёт суффикс из пути
    # (папка вида 25.11.2026 давала пустой файл .2026)
    saveAsFileExtension=.png
  '';

  home.packages = with pkgs; [
    # ── Видео / аудио / просмотр (было в system/packages.legacy) ──
    vlc
    imv
    qview
    feh
    ffmpeg_7
    obs-studio
    pavucontrol
    playerctl
    mpv
    strawberry
    easyeffects

    # ── Документы / офис ──
    evince
    libreoffice
    calibre
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US

    # ── Дизайн ──
    krita
    gimp3
    gcolor3

    # ── Продуктивность ──
    obsidian
    planify
    qalculate-gtk

    # ── Скриншоты / запись ──
    flameshot
    grim
    slurp
    screenkey

    # ── Торренты ──
    qbittorrent
  ];
}
