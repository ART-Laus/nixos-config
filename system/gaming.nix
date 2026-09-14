# system/gaming.nix — Steam, Wine, gamemode (флаг features.gaming)
{ config, lib, pkgs, ... }:
let
  cfg = config.features.gaming or { enable = true; };
in
{
  options.features.gaming.enable = lib.mkEnableOption "gaming (Steam, Wine, gamemode)" // { default = true; };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    # Wine — системная часть (home-часть в home/gaming.nix)
    environment.systemPackages = with pkgs; [
      wineWowPackages.stableFull
      winetricks
      protonup-qt
      steam-run
      mangohud
      # Vulkan — базовый набор (остальное в home при необходимости)
      vulkan-loader
      vulkan-tools
    ];
  };
}
