# home/features/gaming/default.nix — gaming home-часть (пусто, Steam управляется системно)
{ config, lib, ... }:
let
  cfg = config.features.gaming or { enable = true; };
in
{
  config = lib.mkIf cfg.enable {
    # Steam управляется через system/gaming.nix
    # home-пакеты gaming-стека удалены (MangoHud, ProtonUp-Qt и т.д.)
  };
}
