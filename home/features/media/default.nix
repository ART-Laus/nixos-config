# home/features/media/default.nix — медиа, музыка, OBS, дизайн, продуктивность
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # ── Видео / аудио / просмотр (было в system/packages.legacy) ──
    mpv
    imv
    qview
    feh
    ffmpeg_7
    obs-studio
    pavucontrol
    playerctl
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

    # ── Скриншоты / запись ──
    ksnip
    screenkey

    # ── Торренты ──
    qbittorrent
  ];
}
