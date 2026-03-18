home-manager switch --flake .#hmoens

nix run .#homeConfigurations.hmoens.activationPackage

nix flake update
