# home/features/media/default.nix — медиа, музыка, OBS
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    mpv
    imv
    qview
    ffmpeg_7
    obs-studio
    pavucontrol
    playerctl
  ];
}
