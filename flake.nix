{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lcat = {
      url = "github:SakulK/lcat/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    unison = {
      url = "github:ceedubs/unison-nix";
    };
  };

  outputs = inputs: {

    nixosConfigurations =

      let
        custom-overlay = final: prev: {
          stable = inputs.nixpkgs-stable.legacyPackages.${prev.system};
          lcat = inputs.lcat.packages.x86_64-linux.default;
          networkmanager-openvpn = inputs.nixpkgs-stable.legacyPackages.${prev.system}.networkmanager-openvpn;
        };
      in
      {
        saku-nixos = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            "${inputs.nixpkgs}/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix"

            ({ pkgs, ... }: {
              nix.extraOptions = "experimental-features = nix-command flakes";
              nix.registry.nixpkgs.flake = inputs.nixpkgs;
              nixpkgs.overlays = [ custom-overlay inputs.unison.overlay ];

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

            ({ pkgs, ... }: {
              nix.extraOptions = "experimental-features = nix-command flakes";
              nix.registry.nixpkgs.flake = inputs.nixpkgs;
              nixpkgs.overlays = [ custom-overlay inputs.unison.overlay ];

              home-manager.useGlobalPkgs = true;
            })

            ./hosts/thinkpad.nix
          ];
        };
      };
  };
}
