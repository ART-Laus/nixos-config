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
  # GPU newbox: RX 9060 XT = RDNA4 (gfx1201). nixpkgs 26.05 содержит ROCm 6.4.3+,
  # где gfx12 уже в clr.gpuTargets — native RDNA4 без перекрытия. Если когда-нибудь
  # снова увидишь в journalctl ollama "no compatible GPUs" — проверь:
  #   nix eval --impure .#nixosConfigurations.newbox.pkgs.rocmPackages.clr.gpuTargets
  # и при необходимости верни rocmOverrideGfx = "11.0.0" (gfx1100/RDNA3).
  services.ollama = {
    enable = lib.mkDefault true;
    # 26.05: опции acceleration нет — пакет выбирается явно (ollama-rocm собран
    # под все цели из clr.gpuTargets, включая gfx1201 для RX 9060 XT)
    package = pkgs.ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
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
