nix build .#nixosConfigurations.`hostname`.config.system.build.toplevel --accept-flake-config
nvd diff /run/current-system result
