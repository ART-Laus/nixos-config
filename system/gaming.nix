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

    # Wine / Proton / Vulkan — системная часть (home-часть в home/features/gaming)
    environment.systemPackages = with pkgs; [
      wineWowPackages.stableFull
      winetricks
      protonup-qt
      steam-run
      mangohud
      # Vulkan — полный набор из legacy
      vulkan-loader
      vulkan-tools
      vulkan-tools-lunarg
      vulkan-headers
      vulkan-validation-layers
      vulkan-utility-libraries
      vulkan-extension-layer
      gfxreconstruct
      glslang
      spirv-cross
      spirv-headers
      spirv-tools
      vkdisplayinfo
      vk-bootstrap
      dxvk
      vkd3d
      vkd3d-proton
    ];
  };
}
