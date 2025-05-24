[<img src="https://nixos.org/logo/nixos-logo-only-hires.png" width="100" alt="NixOS">](https://nixos.org)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes** - 100% Nix Flakes-based configuration, no Nix channels.
- **User Home Environments** - Reproducible user home environments using _HomeManager_.
- **Linux, WLS and Darwin Hosts** - Declarative configurations for _NixOS_ _WSL_ & _Darwin_ hosts.
- **Bitwarden Managed Secrets** - System wide secrets managed with _Bitwarden Secret Manager_.
- **CVS Scanning** - Automatic CVS vulnerability scanning using _Vulnix_.
- **Continuous Integration** - Backed by continuous integration workflows on _GitHub Actions_ runners.
- **Topology Diagrams** - Automated infrastructure and network diagrams using _nix-topology_.
- **Nix Overlays** - Overlays for packages, utils and tooling.
- **Ad-hoc Shell Environments** - Predefined ad-hoc shell environments for common tools and tasks.
- **Flake Templates** - Flake templates included for bootstrapping common development workspaces.


## Workspace

This workspace follows the following structure:

```
├── assets          # Static assets
├── home            # User HomeManager configurations
├── hosts           # Host NixOS and NixDarwin configurations
├── infrastructure  # Terraform configuration
├── modules         # Nix modules
├── pkgs            # Packages
├── shells          # Ad-hoc shells environments
├── templates       # Flake templates
├── flake.nix       # Flake inputs and outputs
├── lib.nix         # Nix utils
├── overlays.nix    # Package overlays
├── shell.nix       # Workspace development shell
└── topology.nix    # Topology diagram configuration
```
