{
  description = "Your NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Use a specific stable channel
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11"; # Use a specific stable channel
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Your existing dotfiles repository
    dotfiles = {
      url = "github:ART-Laus/dotfiles";
      flake = false; # Treat as a source of files, not a flake itself
    };

      };
      mangowc = {
        url = "github:DreamMaoMao/mangowc";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  
    outputs = { self, nixpkgs, home-manager, dotfiles, mangowc, ... }:    let
      # Define the system architecture
      system = "x86_64-linux"; # Assuming x86_64-linux for your laptop

      # Your username
      username = "artlaus";

      # Common packages for all configurations
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    in {
      # NixOS configurations for your hosts
      nixosConfigurations = {
        # Define your laptop's configuration
        # Replace "msi-laptop" with the actual hostname of your laptop
        # You can find your hostname by running `hostname` in your terminal
        "msi-laptop" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Import your common system modules
            ./modules/common
                          # Import your host-specific configuration
                          ./hosts/msi-laptop/configuration.nix
                          # Enable home-manager for your user on this system
                          home-manager.nixosModules.home-manager {
                            home-manager.useGlobalPkgs = true;
                            home-manager.useUserPackages = true;
                            home-manager.users.${username} = import ./artlaus; # Import your user's home-manager config
                          }
                          mangowc.nixosModules.default
          ];
        };
      };

      # Home Manager configurations for your users
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./artlaus # Import your user's home-manager config
          ];
        };
      };

      # Development environment for working on this flake
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixpkgs-fmt # Nix formatter
            home-manager # home-manager CLI tool
          ];
        };
      };
    };
}