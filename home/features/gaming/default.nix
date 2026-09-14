# home/features/gaming/default.nix — gaming home-часть (mangohud, protonup)
{ config, lib, pkgs, ... }:
let
  cfg = config.features.gaming or { enable = true; };
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mangohud
      protonup-qt
    ];
  };
}
