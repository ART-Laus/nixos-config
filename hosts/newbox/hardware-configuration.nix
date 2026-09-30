# hosts/newbox/hardware-configuration.nix
# Железо нового десктопа (чек DNS от 2025-12-27):
#   CPU     AMD Ryzen 9 9950X3D (16C/32T, AM5, TDP 170 Вт)
#   GPU     Gigabyte Radeon RX 9060 XT 8GB (RDNA4, Navi 48, gfx1201)
#   MB      MSI X870 GAMING PLUS WIFI (X870, Wi-Fi 7 Qualcomm WCN785x, 5GbE RTL8126)
#   RAM     64 GB DDR5-5600 (4×16 Kingston Fury Beast)
#   SSD     Samsung 9100 PRO 1 TB NVMe (PCIe 5.0)
#   HDD     Toshiba DT02ACA200 2 TB SATA 7200rpm
#   Монитор ARDOR GAMING NOVA ULTRA 27" 4K 160 Гц
#
# Разметка по меткам (совпадает с docs/INSTALL.md, этап разметки):
#   SSD  p1 → boot        (FAT32 /boot, 1 ГБ)
#   SSD  p2 → nixos-swap  (swap, 16 ГБ)
#   SSD  p3 → nixos       (ext4 /, остаток SSD)
#   HDD  p1 → data        (ext4 /mnt/data)
#
# ⚠️ После реальной разметки диска прогоните
# `sudo nixos-generate-config --root /mnt` и сверьте строки ниже
# с полученным файлом (секции fileSystems/swapDevices).
{ config, lib, pkgs, ... }:
{
  # ── Платформа ──
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ── Микрокод CPU (AMD) ──
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # ── Initrd: драйверы X870/AM5 ──
  boot.initrd.availableKernelModules = [
    "xhci_pci"     # USB 3.x/4
    "ehci_pci"
    "ahci"         # SATA (Toshiba HDD)
    "nvme"         # Samsung 9100 PRO
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  # amdgpu в initrd — экран включается раньше, без чёрной полосы при старте
  boot.initrd.kernelModules = [ "amdgpu" ];

  # ── Разделы (по меткам) ──
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # HDD 2 ТБ под данные/музыку. nofail — без него система не загрузится,
  # если диск не подключён.
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-label/nixos-swap"; }
  ];
}