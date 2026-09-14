# system/networking-security.nix — сеть, firewall, GPG, polkit, sops
{ config, pkgs, lib, ... }:
{
  # Networking — NetworkManager
  networking.networkmanager.enable = true;
  # hostName задаётся в hosts/msi-laptop/default.nix

  # Firewall — закрыт по умолчанию, точечные открытия — в других модулях
  networking.firewall.enable = true;

  # Time & locale — из старого system/configuration.nix
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
  };
  console.keyMap = "us";

  # Users — перенесите hashedPassword в sops после установки
  users.users.artlaus = {
    isNormalUser = true;
    description = "artlaus";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.zsh;
    # initialHashedPassword = "..."; # сгенерировать: mkpasswd -m sha-512
  };
  programs.zsh.enable = true;

  # GPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # Polkit — ОДИН агент (второй из hyprland.nix exec-once удалён)
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # SOPS — раскомментируйте когда настроите sops-nix
  # sops.defaultSopsFile = ../secrets/secrets.yaml;
  # sops.age.keyFile = "/home/artlaus/.config/sops/age/keys.txt";
}
