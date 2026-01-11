[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes** - 100% _Nix Flakes_-based configuration, no Nix channels.
- **Hybrid Infrastructure** - Local bearmetal hosts combined with cloud resources. 
- **Centralized Identity Management** - Unified identity across all systems via _LDAP_ and _SSSD_.
- **GPG Encrypted & Bitwarden Managed Secrets** - System wide encrypted secrets managed by _bsm_ & _bw_.
- **Secure By Default Operating System** - Hardened _NixOS_ linux based operating system.

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
