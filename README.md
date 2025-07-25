[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes** - 100% _Nix Flakes_-based configuration, no Nix channels.
- **Linux, WLS and Darwin Hosts** - Declarative configurations for _Linux_, _WSL_ & _Darwin_ hosts.
- **Bispoke Wayland Desktop** - Built on top of _niri_, _residence_ provides a scrolling desktop environment.
- **Bitwarden Managed Secrets** - System wide secrets and user passwords managed by _bsm_ & _bw_.
- **CVS Scanning & AV** - Automatic CVS vulnerability scanning using _Vulnix_ and AV providded by _CalmAV_.
- **Automated GCS Backups** - Automated backups to _Google Cloud Storage Buckets_.
- **Peer-to-peer secure VPN** - _Tailscale_ zero config virtual private mesh networking.
- **Private DNS Service** - Prvicy-fixused and security-oriented domain name service by _NextDNS_.
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
