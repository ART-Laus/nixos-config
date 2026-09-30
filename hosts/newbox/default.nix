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

  # Hardware-специфика нового десктопа
  # ── GPU RDNA4: ROCm 6.3.3 (25.05) не знает gfx1201 → Ollama наследует
  #    настройку rocmOverrideGfx из system/services.nix ("11.0.0" = gfx1100).

  # ── Принтер/сканер Pantum M6500W — печать и скан по WiFi/USB
  #    (system/printing.nix: CUPS + pantum-driver + sane-airscan).
}