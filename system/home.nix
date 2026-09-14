{ config, pkgs, inputs, lib, ... }: {
  # This file defines the home-manager configuration for the primary user.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Import all the modular user features
  imports = [
    ../artlaus
  ];

  home = {
    username = "artlaus";
    homeDirectory = "/home/artlaus";

    # Packages that must be installed by home-manager for them to work correctly
    # (e.g., VSCode for extensions)
    packages = with pkgs; [
      (import ../scripts { inherit pkgs; }) # Our custom media scripts
      # vscode # Example
    ];

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox"; # Changed from librewolf as user has firefox installed
      TERMINAL = "alacritty";
      TERM = "alacritty";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      PATH = "$PATH:${config.home.homeDirectory}/go/bin";
    };

    stateVersion = "23.11"; # Match the version from your flake.nix
  };

  # GTK theme settings
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Stylix settings, disabling for specific applications
  stylix = {
    # disabling targets can be done via home-manager
    targets = {
      # vscode.enable = false; # Example
      firefox.enable = false;
    };
  };
}
