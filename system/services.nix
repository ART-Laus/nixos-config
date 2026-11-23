# system/services.nix — display manager (greetd), portals, ollama, VPN, Tor
{ config, pkgs, lib, theme, ... }:
{
  # Display Manager — greetd + tuigreet (утверждено: greetd, Wayland-native)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland --remember --remember-session";
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

  # dconf — нужен Home Manager для gtk/dconf-настроек (иначе падает активация)
  programs.dconf.enable = true;

  services.upower.enable = true;

  # GVFS + Tumbler — общие сервисы для тумбнейлов и виртуальных ФС
  # (Dolphin ставится в home/features/desktop/apps.nix, Xfce-часть удалена)
  services.udisks2.enable = true;
  environment.etc."udisks2/mount_options.conf".text = ''
    [defaults]
    ntfs_drivers=ntfs,ntfs3
  '';
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Ollama — 127.0.0.1 по умолчанию (безопасно, не 0.0.0.0)
  # Ноутбук: AMD Barcelo (1002:15e7, gfx90c) — ROCm не поддерживает gfx90c,
  # поэтому используем Vulkan (RADV), который работает на этом iGPU.
  services.ollama = {
    enable = lib.mkDefault true;
    package = pkgs.ollama-vulkan;
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_IGPU_ENABLE = "1";
    };
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
