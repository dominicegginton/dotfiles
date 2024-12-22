[<img src="https://nixos.org/logo/nixos-logo-only-hires.png" width="100" alt="NixOS">](https://nixos.org)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes** - 100% Nix Flakes-based configuration, no Nix channels.
- **User Home Environments** - Reproducible user home environments using _HomeManager_.
- **NixOS and Darwin Hosts** - Resproducible configurations for _NixOS_ & _Darwin_ hosts.
- **Bitwarden Managed Secrets** - Secrets managed with _Bitwarden Secret Managemer_.
- **CVS Scanning** - Automatic CVS vulnerability scanning using _Vulnix_.
- **Continuous Integration** - Backed by continuous integration workflows on _GitHub Actions_ runners.
- **Base16 Themes** - Base16 theming throughout system and package configurations.
- **Nix Overlays** - Custom Nix overlays for packages, extra utils and tools.
- **Ad-hoc Shell Environments** - Reproducible ad-hoc shell environments for common tools and tasks.
- **Flake Templates** - Flake templates included for bootstrapping workspaces.

> [!CAUTION]
>
> Host and home configurations within this workspace contain secrets values that
> are managed using **Bitwarden Secrets**. Hosts are authenticated using a
> Bitwarden machine account access token specified in **/etc/bitwarden-secrets.env**:
>
> ``` shell
> BWS_PROJECT_ID=<bitwarden-secrets-manager-project-id>
> BWS_ACCESS_TOKEN=<bitwarden-machine-account-access-token>
> ```


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
├── lib.nix         # Nix utils
├── overlays.nix    # Package overlays
└── shell.nix       # Workspace development shell
```
