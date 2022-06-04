{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {

    nixosConfigurations = {
      saku-nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager.nixosModules.home-manager
          "${inputs.nixpkgs}/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix"

          ({ pkgs, ... }:
            let
              overlay-stable = final: prev: {
                stable = inputs.nixpkgs-stable.legacyPackages.${prev.system};
              };
            in { nixpkgs.overlays = [ overlay-stable ]; })

          ({ pkgs, ... }: {
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.package = pkgs.nixFlakes;
            nix.registry.nixpkgs.flake = inputs.nixpkgs;

            home-manager.useGlobalPkgs = true;
          })

          ./hosts/tower.nix
        ];
      };
      saku-thinkpad = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager.nixosModules.home-manager
          "${inputs.nixpkgs}/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix"

          ({ pkgs, ... }:
            let
              overlay-stable = final: prev: {
                stable = inputs.nixpkgs-stable.legacyPackages.${prev.system};
              };
            in { nixpkgs.overlays = [ overlay-stable ]; })

          ({ pkgs, ... }: {
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.package = pkgs.nixFlakes;
            nix.registry.nixpkgs.flake = inputs.nixpkgs;

            home-manager.useGlobalPkgs = true;
          })

          ./hosts/thinkpad.nix
        ];
      };
    };
  };
}
