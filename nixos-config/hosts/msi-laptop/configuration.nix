{ config, pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Import your common system modules
  imports = [
    # Add any common system modules here, e.g.,
    # ./modules/common
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg"; # Adjust to your timezone

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Configure keyboard layout
  services.xserver.layout = "us,ru";
  services.xserver.xkbOptions = "grp:ctrl_shift_toggle"; # Ctrl+Shift to switch layout

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.artlaus = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Add necessary groups
    shell = pkgs.zsh; # Set Zsh as default shell
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
                            programs.mangowc.enable = true; # Enable MangoWC program
              
                            environment.systemPackages = with pkgs; [
                              # Add any system-wide packages here
                              git
                              wget
                              neovim
                              wezterm
                              wmenu
                              wl-clipboard
                              grim
                              slurp
                              swaybg
                              firefox
                            ];
                      
                            # Enable font configuration
                            fonts.fontconfig.enable = true;
                            fonts.fonts = with pkgs; [
                              nerd-fonts.jetbrains-mono
                            ];  # Set default font for X11 (may be overridden by desktop environment)
                    services.xserver.defaultFont = {
                      name = "JetBrains Mono Nerd Font";
                      size = 14;
                    };
              
                            # Enable the X11 windowing system.
                            services.xserver.enable = true;
                            services.xserver.windowManager.session = [{ name = "mangowc"; }]; # Set MangoWC as the window manager
                      
                            # Enable the GNOME Desktop Environment.
                            # services.xserver.displayManager.gdm.enable = true;
                            # services.xserver.desktopManager.gnome.enable = true;
                      
                            # Or a minimal window manager like i3
                            # services.xserver.windowManager.i3.enable = true;  # Enable networking  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking changes.
  # It is recommended to set this value only once, and then not change it,
  # even though it is possible to update this value.
  #
  # Do not change this value until you have read the appropriate release notes!
  system.stateVersion = "23.11"; # Did you read the configuration.nix documentation?
}
