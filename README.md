[<img src="https://nixos.org/logo/nixos-logo-only-hires.png" width="100" alt="NixOS">](https://nixos.org)

# There's no place like ~

```ocaml
Declarative System Configuration
NixOS / NixDarwin / HomeManager / SopsNix
```

## Features

- **Nix Flakes** 100% Nix Flakes based configuration, no Nix channels.
- **Disk Management** Declarative disk management using Disko.
- **Encrypted Secrets** Stored configuration secrets are encrypted using SopsNix.
- **User Home Environments** Reproducible user home environments using HomeManager.
- **MacOS Hosts** NixDarwin provides support for MacOS hosts.
- **Continuous Integration** Backed by continuous integration workflows on GitHub Actions runners.
- **Nix Dev Shells** Reproducible environments for common tools and tasks.
- **Flake Templates** Easily create new Nix Flakes using templates for common cases.
- **Nix Systems Manager** Manage nix system configurations with a single command.

## Workspace

This workspace follows the following structure:

```
├── home            # Home manager configurations
├── hosts           # Host NixOS and NixDarwin configurations
├── lib             # Nix module helpers
├── modules         # Nix modules
├── overlays        # Nix package overlays
├── pkgs            # Nix packages
├── scripts         # Scripts
├── shells          # Nix development shells
├── templates       # Flake templates
└── flake.nix       # Nix Flake inputs and outputs
```

## Eye Candy

![2024-02-24_09-50](https://github.com/dominicegginton/dotfiles/assets/28626241/658cfb6d-96aa-4692-ad0e-891c7a081a60)

<p align="center">
    <sub>Last Updated: 2024-02-24</sub>
</p>

## Documentation

```ocaml
Coming Soon
```
