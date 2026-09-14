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
      enableOnBoot = false;
    };
    users.users.artlaus.extraGroups = [ "docker" ];
  };
}
