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
- **Zero Trust Networking** – _Tailscale_ mesh VPN with _Tailscale Serve_ exposure for selected services.
- **SOPS Secrets Management** – Host secrets managed declaratively with _sops-nix_ and age/SSH keys.
- **Automated Cloud Backups** – Service data backups to _Google Cloud Storage_ via systemd timers.
- **Self-Hosted CI Runners** – Declarative _GitHub Actions_ self-hosted runner support on NixOS hosts.
- **Media & Home Services** – Declarative modules for _Immich_, _Frigate_, _Jellyfin_, _Home Assistant_, and more.
- **Security & Compliance** – Hardened defaults, run0 integration, and SBOM-enabled package workflows.
- **Continuous Integration** – Automated checks and workflows with _GitHub Actions_ and flake-native outputs.
- **Automated Garbage Collection** – System prunes old Nix store paths automatically.
- **Desktop Environments** – Wayland _GNOME_ & _DriftWM_ desktop environments.

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
