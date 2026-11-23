{ config, lib, ... }:
let
  cfg = config.artlaus.desktop.bar;
in
{
  imports = [
    ./quickshell.nix
  ];

  options.artlaus.desktop.bar = {
    enable = lib.mkEnableOption "desktop bar" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {};
}
