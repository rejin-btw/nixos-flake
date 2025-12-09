{
  description = "NixOS + Home Manager + flake for rejin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      ...
    }:
    let
      system = "x86_64-linux";

      # Define the Unstable Packages
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

    in
    {
      nixosConfigurations = {
        rejin-nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/default.nix
            home-manager.nixosModules.home-manager
            {
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };
      };

      # 2. THE NEW BOOTSTRAP BLOCK (Add this!)
      # This is the "Universal Slot" your install script will use.
      bootstrap = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/bootstrap/default.nix
          {
            # Essential settings to prevent "checkUnmatched" crashes during install
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
            nixpkgs.config.allowUnfree = true;
            networking.hostName = "bootstrap";
          }
        ];
      };
    };

  homeConfigurations = {
    rejin = home-manager.lib.homeManagerConfiguration {
      # Define pkgs with explicit system
      pkgs = import nixpkgs {
        system = "x86_64-linux"; # Explicit system here
        config = {
          allowUnfree = true;
        };
      };

      # Pass unstable packages
      extraSpecialArgs = {
        inherit pkgs-unstable;
      };

      # Load your home-manager module
      modules = [
        ./home/rejin.nix
      ];
    };
  };

}
