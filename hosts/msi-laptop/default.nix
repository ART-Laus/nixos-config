# hosts/msi-laptop/default.nix — единая точка входа для хоста msi-laptop
# Импортирует system (NixOS) и home (Home Manager) как независимые кубики
{ inputs, ... }:
{
  imports = [
    # Hardware — генерируется nixos-generate-config на реальном железе
    ./hardware-configuration.nix

    # System — отвечает за машину
    ../../system/nix.nix
    ../../system/boot-hardware.nix
    ../../system/networking-security.nix
    ../../system/services.nix
    ../../system/virtualization.nix
    ../../system/packages.nix
  ];

  # Host-specific overrides (если нужно)
  networking.hostName = "msi-laptop";

  # Feature flags — единое место правды (см. docs/architecture.md §3)
  # Раскомментируйте чтобы выключить кубик:
  # features.gaming.enable = false;
  # features.virtualization.docker.enable = false;
}
