[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes** - 100% _Nix Flakes_-based configuration, no Nix channels.
- **Linux, WLS and Darwin Hosts** - Declarative configurations for _Linux_, _WSL_ & _Darwin_ hosts.
- **Scrolling Wayland Desktop** - Bispoke scrolling desktop environment with _niri_ & _residence_ for _Linux_ hosts.
- **AV & CVS Scanning** - Automatic CVS vulnerability scanning using _Vulnix_ and AV providded by _CalmAV_.
- **Bitwarden Managed Secrets** - Infrastructure, system and local user secrets managed with _Bitwarden Secret Manager_.
- **Automated Backups to GCS** - Automated backups to _Google Cloud Storage Buckets_.
- **Continuous Integration** - Backed by continuous integration workflows on _GitHub Actions_ runners.
- **Binary Caching** - Binaries are cached on _Cachix_ for fast builds of development shells and packages.
- **Topology Diagrams** - Automated infrastructure and network diagrams using _nix-topology_.
- **Nix Overlays** - Overlays for packages, utils, and tooling.
- **Ad-hoc Shell Environments** - Predefined ad-hoc shell environments for common tools and tasks.
- **Development Workspace Templates** - _Flake_ templates for bootstrapping common development workspaces.


## Workspace

This workspace follows the following structure:

```
├── .github/workflows # GitHub Actions workflows
├── assets            # Static assets
├── home              # User HomeManager configurations
├── hosts             # Host NixOS and NixDarwin configurations
├── infrastructure    # Terraform configuration
├── modules           # Nix modules
├── pkgs              # Package definitions
├── shells            # Ad-hoc shells environments
├── templates         # Development workspace Templates
├── flake.nix         # Nix flake inputs & outputs
├── lib.nix           # Nix utils
├── overlays.nix      # Package overlays
├── shell.nix         # Workspace development shell
└── topology.nix      # Topology diagram configuration
```
