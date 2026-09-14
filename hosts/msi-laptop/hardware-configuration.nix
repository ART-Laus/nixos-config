# hosts/msi-laptop/hardware-configuration.nix
# ⚠️ ЗАГЛУШКА — замените на реальный файл, сгенерированный `nixos-generate-config` на железе
# На реальном железе: sudo nixos-generate-config --show-hardware-config > hosts/msi-laptop/hardware-configuration.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Пример — ЗАМЕНИТЕ на реальные UUID с `blkid`
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
  #   fsType = "ext4";
  # };
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/XXXX-XXXX";
  #   fsType = "vfat";
  # };
  # swapDevices = [{ device = "/dev/disk/by-uuid/YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"; }];

  # Заглушка чтобы `nixos-rebuild dry-build` не падал в WSL (не используется на реальном железе)
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
