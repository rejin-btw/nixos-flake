{
  description = "NixOS + Home Manager + flake for rejin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    #stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      rejin-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/default.nix
          home-manager.nixosModules.home-manager
          #stylix.nixosModules.stylix
        ];
        specialArgs = { pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; };
      };
    };

    homeConfigurations = {
      rejin = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        modules = [
          ./home/rejin.nix
          #stylix.homeManagerModules.stylix
        ];
        extraSpecialArgs = { pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; }; };
        username = "rejin";
        homeDirectory = "/home/rejin";
      };
    };
  };
}

