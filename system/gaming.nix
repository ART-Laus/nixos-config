# system/gaming.nix — Steam (флаг features.gaming)
{ config, lib, pkgs, ... }:
let
  cfg = config.features.gaming or { enable = true; };
in
{
  options.features.gaming.enable = lib.mkEnableOption "gaming (Steam)" // { default = true; };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
