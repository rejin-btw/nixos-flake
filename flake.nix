{
  description = "NixOS + Home Manager + flake for rejin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
    };
    dotfilesPath = self.path + "/dotfiles";  # Correct absolute path for dotfiles inside flake root
  in {
    nixosConfigurations = {
      rejin-nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/default.nix
          home-manager.nixosModules.home-manager
          {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          }
        ];
        specialArgs = { pkgs = pkgs; };
      };
    };

    homeConfigurations = {
      rejin = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          # Pass dotfilesPath as an extra argument to your home module
          (import ./home/rejin.nix {
            inherit pkgs;
            lib = pkgs.lib;
            dotfilesPath = dotfilesPath;
          })
        ];
        extraSpecialArgs = { inherit pkgs; };
      };
    };
  };
}

