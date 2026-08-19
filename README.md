[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

```ocaml
Declarative System, Package & Home Configurations - WIP Always
```

## Features

- **Nix-Native OS & Environments**:
  - 100% declarative system and user configs via Nix Flakes & Home Manager.
  - Multi-platform support: bare-metal, virtual machines, and WSL.
  - Custom package overlays, automated store garbage collection and schelduled system upgrades.
- **Hardening, Security & Compliance**:
  - **Fortified Kernel**: Strict sysctls, Yama, ASLR, and memory scrubbing.
  - **Ephemeral Root**: Ephemeral `/` (Btrfs rollback) with `/persist` mapping.
  - **Identity & Elevation**: Zero-sudo `run0`, SSSD OAuth2 authentication and PAM lockouts.
  - **Hardware Roots**: TPM 2.0 and mandatory interactive Yubikey auth.
  - **Isolation**: Bus-level USBGuard, default-drop `nftables`, and AppArmor.
  - **Runtime Secrets**: Git-encrypted age/SOPS decrypted at activation time.
  - **Auditing & Compliance**: Auditd, OpenSCAP tooling, and FIPS 140-3 validated crypto.
- **Hybrid Infrastructure & Orchestration**:
  - Multi-host infrastructure managed via Terraform on GCP.
  - Journald logs ship to GCP Cloud Logging via a Vector agent.
  - Automated systemd cloud backups to GCS buckets.
  - Private Harmonia binary cache for faster Nix deployments.
  - Self-hosted GitHub Actions runner orchestration on NixOS.
  - Host network topology generated natively via `nix-topology`.
  - Support for OIDC/Oauth2 backed by Tailscale identities for SSO across all services.
- **Desktop Environments & Services**:
  - Wayland-native GNOME desktop experience.
  - Declarative media/home services accessible over the secure Tailnet VPN.
