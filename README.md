[<img src="https://nixos.org/logo/nixos-logo-only-hires.png" width="100" alt="NixOS">](https://nixos.org)

# There's no place like ~

```ocaml
Declarative System & Package Configurations - WIP Always
NixOS | NixDarwin | NixOS-WSL | HomeManager | SopsNix |
```

## Features

- **Nix Flakes** - 100% Nix Flakes-based configuration, no Nix channels.
- **User Home Environments** - Reproducible user home environments using _HomeManager_.
- **NixOS, Darwin and WSL Hosts** - Resproducible hosts configurations for _NixOS_, _Darwin_ and _WSL_ based platforms.
- **Encrypted Secrets** - Stored configuration secrets are encrypted with _SopsNix_.
- **Continuous Integration** - Backed by continuous integration workflows on _GitHub Actions_ runners.
- **Base16 Themes** - Base16 theming throughout system and package configurations.
- **Ad-hoc Shell Environments** - Reproducible ad-hoc shell environments for common tools and tasks.
- **Flake Templates** - Flake templates included for bootstrapping workspaces.

> [!CAUTION]
>
> Most host & home configurations within this workspace contain encrypted secrets,
> which means that they **cannot** be built and replicated successfully without
> the necessary decryption keys. This is not a community framework, but you are
> invited to explore the modules and countless lines of Nix I have written, _at
> my expense, for the community's convenience_.

## Workspace

This workspace follows the following structure:

```
├── home            # User HomeManager configurations
├── hosts           # Host NixOS and NixDarwin configurations
├── modules         # Nix modules
├── pkgs            # Packages
├── shells          # Ad-hoc shells enviroments
├── templates       # Flake templates
├── flake.nix       # Flake inputs and outputs
├── lib.nix         # Libary untils
├── overlays.nix    # Nix overlays
└── shell.nix       # Workspace development shell
```

## Eye Candy

![2024-02-24_09-50](https://github.com/dominicegginton/dotfiles/assets/28626241/658cfb6d-96aa-4692-ad0e-891c7a081a60)

<p align="center">
    <sub>Last Updated: 2024-02-24</sub>
</p>
