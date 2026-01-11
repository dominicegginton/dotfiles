[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

``` ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes** - 100% _Nix Flakes_-based configuration, no Nix channels.
- **Hybrid Infrastructure** - _Nix_ & _Terraform_ defined local bearmetal hosts and cloud resources. 
- **Centralized Identity Management** (_testing_) - Globally unified user identity via _LDAP_ and _SSSD_.
- **User Home Management** (_legacy_) - Per-user declarative configuration via _HomeManager_.
- **Zero Trust Networking** - _Tailscale_ provided private mesh networking across all infrastructure nodes. 
- **Secret Management** (_testing_) - _Google Secret Manager_ based secret storage and distribution.
- **Bitwarden Managed Secrets** (_legacy_) - System wide encrypted secrets managed by _bsm_ & _bw_.
- **Secure By Default Operating System** - Hardened _NixOS_ linux based operating system.
- **Desktop Environments** - Fully featured wayland _GNOME_ desktop environment.

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
├── flake.nix         # Nix flake
├── lib.nix           # Nix utils
├── overlays.nix      # Package overlays
├── shell.nix         # Workspace development shell
└── topology.nix      # Topology module configuration
```
