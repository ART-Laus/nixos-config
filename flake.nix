{
  description = "Artlaus NixOS — модульный конструктор (hosts + features + theme)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, ... }@inputs:
    let
      system = "x86_64-linux";
      username = "artlaus";

      # Theme — единственный источник (утверждено: theme/ в корне)
      theme = import ./theme;

      # pkgs с allowUnfree + overlays (если нужны)
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Совместимость: pkgs2/spkgs → pkgs (старые модули используют pkgs2)
      # После миграции artlaus/ → home/features/ заменить pkgs2 → pkgs
      specialArgs = {
        inherit inputs theme username;
        pkgs2 = pkgs;
        spkgs = pkgs;
        pkgs-unstable = pkgs-unstable;
      };
    in
    {
      nixosConfigurations = {
        "msi-laptop" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs;
          modules = [
            ./hosts/msi-laptop/default.nix

            # Home Manager как NixOS модуль (новый путь: home/)
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = import ./home;
            }
          ];
        };


      };

      # Standalone Home Manager (для `home-manager switch`)
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgs;
        modules = [ ./home ];
      };

      # Dev shell
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nix
          git
        ];
      };
    };
}
