# This is the main system configuration file.
# It imports the other configuration files from this directory 
# and sets system-wide options.

{ config, pkgs, inputs, ... }:

{
  imports = [
    # Import system-wide packages, fonts, services, etc.
    ./packages.nix

    # Import the home-manager configuration for the user.
    ./home.nix
  ];

  # --- Basic NixOS Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Set your time zone.
  time.timeZone = "Europe/Moscow"; # Please change to your timezone if this is incorrect

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Bootloader ---
  # GRUB is a safe default. 
  # If you use UEFI, systemd-boot is another good option.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # IMPORTANT: Change this to your boot device
  
  # --- Networking ---
  # Use NetworkManager for network management.
  networking.networkmanager.enable = true;
  networking.hostName = "nixos"; # Define your hostname.

  # --- Users ---
  # Define a user account.
  users.users.artlaus = {
    isNormalUser = true;
    description = "artlaus";
    extraGroups = [ "networkmanager" "wheel" ]; # 'wheel' allows sudo
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}