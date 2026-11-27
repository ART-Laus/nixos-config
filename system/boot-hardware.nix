# system/boot-hardware.nix — загрузчик, графика, звук, bluetooth, питание
{ config, lib, pkgs, ... }:
{
  # Boot — systemd-boot для UEFI (замените если нужен GRUB/Lanzaboote)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Kernel — свежий для Hyprland и amdgpu
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # MSI Modern 15 B7M: встроенная камера выключена в EC по умолчанию.
  # Взводим бит 0x2E.1 (webcam on). Бит 0x2F.1 уже выставлен — это значит
  # «не заблокирована» (в msi-ec это значение инвертируется).
  # ec_sys нужен только на время записи, после неё модуль выгружается.
  systemd.services.enable-builtin-webcam = {
    description = "Enable MSI built-in webcam via Embedded Controller";
    wantedBy = [ "multi-user.target" ];
    after = [ "sys-kernel-debug.mount" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      io=/sys/kernel/debug/ec/ec0/io
      [ -e "$io" ] || exit 0

      ${pkgs.kmod}/bin/modprobe -r ec_sys 2>/dev/null || true
      ${pkgs.kmod}/bin/modprobe ec_sys write_support=1 || exit 0

      # Не трогаем EC, если камера уже включена: повторная запись того же
      # значения вызывает временный USB disconnect.
      cur=$(${pkgs.coreutils}/bin/dd if="$io" bs=1 skip=46 count=1 status=none \
        | ${pkgs.coreutils}/bin/od -An -tu1 | ${pkgs.coreutils}/bin/tr -d ' \n')
      if [ $((cur & 2)) -eq 0 ]; then
        # 0x2E = 0x0B: выставлен бит 1 (webcam)
        printf '\013' | ${pkgs.coreutils}/bin/dd of="$io" bs=1 seek=46 count=1 conv=notrunc status=none
      fi

      ${pkgs.kmod}/bin/modprobe -r ec_sys 2>/dev/null || true
    '';
  };

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

  # Logind — сон/гибернация, крышка и кнопки питания отключены в hosts/newbox/default.nix

  # Firmware updates (X870 — ME/BIOS/фирмварь WiFi и GPU через fwupd)
  services.fwupd.enable = true;
}
