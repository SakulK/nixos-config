{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

          ({ pkgs, ... }: {
            nix.extraOptions = "experimental-features = nix-command flakes";
            nix.package = pkgs.nixFlakes;
            nix.registry.nixpkgs.flake = inputs.nixpkgs;

            home-manager.useGlobalPkgs = true;
          })

          ./hosts/tower.nix
        ];
      };
    };
  };
}
