{ config, pkgs, ... }:

{
  # Let Home Manager manage your dotfiles
  home.enable = true;

  # Define a home directory for the user.
  home.username = "artlaus";
  home.homeDirectory = "/home/artlaus"; # Adjust this to your actual home directory

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home.stateVersion records with the following command:
  #
  #  home-manager switch --update-flake-lock
  #
  # For example, to update from 23.11 to 24.05:
  #
  #  home.stateVersion = "24.05";
  home.stateVersion = "23.11"; # Placeholder, user should update this

  # Import our custom home-manager modules
  imports = [
    ./modules/home-manager/config/nvim
    ./modules/home-manager/config/wezterm.nix
    ./modules/home-manager/config/zsh.nix
    ./modules/home-manager/config/starship.nix
    ./modules/home-manager/config/firefox.nix
    ./modules/home-manager/config/spotify.nix
    ./modules/home-manager/config/yazi
    # Add other config modules here
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # Add any user-specific packages here
  ];

  # Add any other home-manager options here
}