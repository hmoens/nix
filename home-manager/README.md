# Home Manager

## Apply Configuration

```bash
# Auto-detect targets based on folders that are present:
nix run .#homeConfigurations.default.activationPackage

# Explicit targets:
nix run .#homeConfigurations.hmoens.activationPackage
nix run .#homeConfigurations.hmoens-work.activationPackage
```

## Update

```bash
nix flake update
```
