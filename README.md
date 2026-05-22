[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix Flakes & Reproducibility** – 100% _Nix Flakes_-based, reproducible builds, no channels required.
- **Hybrid Infrastructure** – _Nix_ and _Terraform_ define bare-metal, VMs, and cloud (GCP) resources.
- **Automated Topology** – _nix-topology_ visualizes and manages network and host relationships.
- **Custom Package Overlays** – Overlays override upstream packages and define custom ones.
- **Multi-Platform Support** – Supports bare-metal, VMs, and WSL environments.
- **User Home Management** – Per-user declarative config with _HomeManager_.
- **Centralized Identity** (_testing_) – Unified user management via _LDAP_ and _SSSD_.
- **Zero Trust Networking** – _Tailscale_ mesh VPN links all nodes securely.
- **Secrets Management** (_testing_) – _Google Secret Manager_ for secure secrets distribution.
- **Bitwarden Secrets** – System-wide encrypted secrets via _Bitwarden CLI_.
- **Secrets Encryption** – All secrets are encrypted at rest and in transit.
- **Security & Compliance** – SBOM generation, vuln scanning, and system hardening by default.
- **Continuous Integration** – Automated builds and checks with _GitHub Actions_.
- **Automated Garbage Collection** – System prunes old Nix store paths automatically.
- **Fast Local Development** – Dev shells with all required tools and formatters.
- **Desktop Environments** – Wayland _GNOME_ (and _Niri_) desktop environments.

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
