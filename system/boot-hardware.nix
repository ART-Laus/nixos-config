# system/boot-hardware.nix — загрузчик, графика, звук, bluetooth, питание
{ config, lib, pkgs, ... }:
{
  # Boot — systemd-boot для UEFI (замените если нужен GRUB/Lanzaboote)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Kernel — свежий для Hyprland и amdgpu
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Graphics — amdgpu + OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;
  hardware.enableAllFirmware = true;

  # Audio — PipeWire (заменяет отсутствие звука в старом конфиге)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Power — десктоп (без батареи/крышки), профили производительности в трее
  services.power-profiles-daemon.enable = true;

  # SSD trim — Samsung 9100 PRO NVMe (fstrim.timer)
  services.fstrim.enable = true;

  # Logind — дефолты (крышки нет; если захочется авто-suspend для idle —
  # повесить в swayidle, см. home/features/desktop/lockscreen/swayidle.nix)

  # Firmware updates (X870 — ME/BIOS/фирмварь WiFi и GPU через fwupd)
  services.fwupd.enable = true;
}
