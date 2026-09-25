# system/virtualization.nix — Docker / Podman (флаг features.virtualization)
{ config, lib, pkgs, ... }:
let
  cfg = config.features.virtualization or { enable = false; };
in
{
  options.features.virtualization.enable = lib.mkEnableOption "virtualization (Docker)" // { default = false; };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    users.users.artlaus.extraGroups = [ "docker" ];

    # SMB client для монтирования библиотеки с ноутбука
    environment.systemPackages = with pkgs; [
      cifs-utils
      smbclient
      mountcifs
    ];
  };
}
