[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes** - 100% _Nix Flakes_-based configuration, no Nix channels.
- **Gnome Desktop Environment** - Full featured Gnome desktop environment.
- **GPG Encrypted & Bitwarden Managed Secrets** - System wide encrypted secrets managed by _bsm_ & _bw_.
- **Comprehensive Backups** - Automated backups to _Google Cloud Storage Buckets_.
- **Peer-to-peer secure VPN** - _Tailscale_ zero config virtual private mesh networking.
- **Private DNS Service** - Prvicy-fixused and security-oriented domain name service provided by _NextDNS_.
- **Continuous Integration** - Backed by continuous integration workflows on _GitHub Actions_ runners.

## Workspace

This workspace follows the following structure:

```
├── assets            # Static assets
├── home              # User HomeManager modules 
├── hosts             # Host NixOS modules 
├── infrastructure    # Terraform infrastructure
├── modules           # NixOS modules
├── pkgs              # Package definitions
├── shells            # Ad-hoc shells environments
├── templates         # Nix flake templates
├── flake.nix         # Nix flake
├── lib.nix           # Nix utils
├── overlays.nix      # Package overlays
├── shell.nix         # Workspace development shell
└── topology.nix      # Topology diagram configuration
```
