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

     # Discovery tools — flake-based packages
     nixmate.url = "github:daskladas/nixmate";
     nixard.url = "github:manelinux/nixard";
     verynix.url = "github:mipmip/verynix";
     anima.url = "github:Yazelix/anima";
     super-comma.url = "github:vivekanandan-ks/super-comma-nix";
     nixy.url = "github:yusukeshib/nixy";
     niux.url = "github:sayavc/niux";
     nix-bonsai.url = "github:0xatrilla/nix-bonsai";
   };

    outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, nixmate, nixard, verynix, anima, super-comma, nixy, niux, nix-bonsai, ... }@inputs:
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

       # Внешние flake-пакеты
       flakePkgs = {
         nixmate = nixmate.packages.${system}.default;
         nixard = nixard.packages.${system}.default;
         verynix = verynix.packages.${system}.default;
         anima = anima.packages.${system}.default;
         super-comma = super-comma.packages.${system}.default;
         nixy = nixy.packages.${system}.default;
         niux = niux.packages.${system}.default;
         nix-bonsai = nix-bonsai.packages.${system}.default;
       };

       # Совместимость: pkgs2/spkgs → pkgs (старые модули используют pkgs2)
       # После миграции artlaus/ → home/features/ заменить pkgs2 → pkgs
        specialArgs = {
          inherit inputs theme flakePkgs;
          pkgs2 = pkgs;
          spkgs = pkgs;
          pkgs-unstable = pkgs-unstable;
        };
    in
    {
      nixosConfigurations = {
        "newbox" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = specialArgs;
          modules = [
            ./hosts/newbox/default.nix

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
