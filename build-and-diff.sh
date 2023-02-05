nix build .#nixosConfigurations.`hostname`.config.system.build.toplevel
nvd diff /run/current-system result
