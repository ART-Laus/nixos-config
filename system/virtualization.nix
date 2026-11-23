{ config, lib, pkgs, ... }:
let
  cfg = config.features.virtualization or { enable = false; };
in
{
  options.features.virtualization.enable = lib.mkEnableOption "virtualization (Podman)" // { default = false; };

  config = lib.mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    users.users.artlaus.extraGroups = [ "podman" ];

    environment.systemPackages = with pkgs; [
      cifs-utils
      samba
      podman-compose
    ];
  };
}
