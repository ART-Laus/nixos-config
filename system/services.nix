# system/services.nix — display manager (greetd), portals, ollama, VPN, Tor
{ config, pkgs, lib, theme, ... }:
{
  # Display Manager — greetd + tuigreet (утверждено: greetd, Wayland-native)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland --remember --remember-session";
        user = "greeter";
      };
    };
  };

  # XDG portals — для Hyprland (скриншаринг, файл-пикеры)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Thunar + GVFS (из старого packages.nix)
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-media-tags-plugin
      thunar-archive-plugin
      thunar-volman
    ];
  };
  programs.xfconf.enable = true;

  # Ollama — 127.0.0.1 по умолчанию (безопасно, не 0.0.0.0)
  services.ollama = {
    enable = lib.mkDefault true;
    acceleration = "rocm";
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
    rocmOverrideGfx = "10.3.0";
  };

  # Nix-LD — для неродных бинарей
  programs.nix-ld.enable = true;

  # AppImage
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [ libpng libpng12 libepoxy pcre2 double-conversion ];
    };
  };

  # Tor — анонимный прокси + hidden services
  services.tor = {
    enable = true;
    client.enable = true;
    openFirewall = false;
    settings = {
      HiddenServiceDir = "/var/lib/tor/hidden_service/";
      HiddenServicePort = "80 127.0.0.1:8080";
    };
  };

  # OpenVPN — клиентские конфиги
  environment.etc."openvpn/client/example.conf".source = ./openvpn/client/example.conf;

  # Tailscale — Mesh VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = false;
    authKeyFile = if builtins.getEnv "TAILSCALE_AUTHKEY_FILE" == "" then null else builtins.toPath (builtins.getEnv "TAILSCALE_AUTHKEY_FILE");
  };
}
