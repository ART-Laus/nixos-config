# system/printing.nix — печать и сканирование (Pantum M6500W / M6502W)
# МФУ с чека DNS: два уличных лазерника Pantum M6500-серии.
# Подключение: USB или WiFi (AirPrint/eSCL), печать и скан driverless.
{ config, pkgs, lib, ... }:
{
  # ── Печать (CUPS) ──
  services.printing.enable = true;
  # Проприетарный драйвер Pantum (M6000/M6200/M6500/M6550/M6600/MS6000 серии)
  services.printing.drivers = [ pkgs.pantum-driver ];

  # mDNS — чтобы CUPS/sane находили МФУ по сети (Pantum-XXXX.local)
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.avahi.openFirewall = true;

  # ── Сканирование ──
  hardware.sane.enable = true;
  # WebScan/eSCL по WiFi (Pantum M6500W поддерживает AirScan) + ipp-usb для USB
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
  services.udev.packages = [ pkgs.sane-airscan ];
  services.ipp-usb.enable = true;

  # ── Пусковая зона фаерволла (остальное закрыто) ──
  # 5353/udp открыт выше через avahi.openFirewall (mDNS-обнаружение МФУ)
  # Печать по IPP остаётся на localhost — наружу CUPS не слушает.
}