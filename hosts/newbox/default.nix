# hosts/newbox/default.nix — единая точка входа для хоста newbox (новый десктоп)
# Импортирует system (NixOS) и home (Home Manager) как независимые кубики
{ inputs, ... }:
{
  imports = [
    # Hardware — предзаполнено под новый десктоп (см. файл), при установке
    # сверяется с `nixos-generate-config`
    ./hardware-configuration.nix

    # System — отвечает за машину
    ../../system/nix.nix
    ../../system/boot-hardware.nix
    ../../system/networking-security.nix
    ../../system/services.nix
    ../../system/virtualization.nix
    ../../system/packages.nix
    ../../system/printing.nix
  ];

  # Host-specific overrides
  networking.hostName = "newbox";

  # Feature flags — единое место правды (см. docs/architecture.md §3)
  features.virtualization.enable = true;

  powerManagement.enable = false;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "ignore";
    HandleRebootKey = "ignore";
    HandleRebootKeyLongPress = "ignore";
    HandleSuspendKey = "ignore";
    HandleSuspendKeyLongPress = "ignore";
    HandleHibernateKey = "ignore";
    HandleHibernateKeyLongPress = "ignore";
    IdleAction = "ignore";
    IdleActionSec = "0";
  };

  # Hardware-специфика ноутбука
  # ── GPU AMD Barcelo (gfx90c): ROCm не поддерживается, Ollama через Vulkan.

  # ── Принтер/сканер Pantum M6500W — печать и скан по WiFi/USB
  #    (system/printing.nix: CUPS + pantum-driver + sane-airscan).

  nixpkgs.overlays = [
    (final: prev: {
      pgadmin4 = prev.pgadmin4.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
