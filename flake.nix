{
  description = "NixOS + Home Manager + flake for rejin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    
    # We keep this to lock the version, but we won't pass it as a path anymore
    dotfiles.url = "path:/home/rejin/dotfiles";
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, ... }:
  let
    system = "x86_64-linux";
    # DELETE THIS LINE: dotfilesPath = "${dotfiles}/scripts";
  in {
    nixosConfigurations = {
      rejin-nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/default.nix
          home-manager.nixosModules.home-manager
          {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };

    homeConfigurations = {
      rejin = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        modules = [
          ./home/rejin_live.nix
        ];
        extraSpecialArgs = {
          # DELETE THIS LINE: inherit dotfilesPath;
          # You don't need to pass anything extra now!
        };
      };
    };
  };
}
