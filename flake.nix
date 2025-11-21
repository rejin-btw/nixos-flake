{
  description = "NixOS + Home Manager + Stylix flake for rejin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    stylix.url = "github:danth/stylix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, stylix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
        };
      in {
        # NixOS system configuration (edit "rejin-nixos" as you like)
        nixosConfigurations = {
          rejin-nixos = nixpkgs.lib.nixosSystem {
            system = system;
            modules = [
              ./hosts/default.nix
              home-manager.nixosModules.home-manager
              stylix.nixosModules.stylix
            ];
            specialArgs = { inherit pkgs; };
          };
        };

        # Home Manager standalone configuration (edit username if needed)
        homeConfigurations = {
          rejin = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            modules = [
              ./home/rejin.nix
              stylix.homeManagerModules.stylix
            ];
            extraSpecialArgs = { inherit pkgs; };
            username = "rejin";
            homeDirectory = "/home/rejin";
          };
        };
      });
}

