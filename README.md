[<img src="https://raw.githubusercontent.com/dominicegginton/dotfiles/refs/heads/main/assets/nix.svg" width="100" alt="">](https://github.com/dominicegginton/dotfiles)

# There's no place like ~

```ocaml
Declarative hardened amnesic nixos configuration
```

## Features

- **Nix-Native OS & Environments**:
  - 100% declarative system and user configs via Nix Flakes & Home Manager.
  - Multi-platform support: bare-metal, virtual machines, and WSL.
  - Custom package overlays, automated store garbage collection and scheduled system upgrades.
- **Hardening, Security & Compliance**:
  - **Fortified Kernel**: Strict sysctls, Yama, ASLR, and memory scrubbing.
  - **Amnesic Root & Impermanence**: Ephemeral `/` (Btrfs rollback on boot) with `/persist` mapping.
  - **Identity & Elevation**: Zero-sudo `run0`, SSSD OAuth2 authentication and PAM lockouts.
  - **Hardware Roots & Anti-Tamper**: TPM 2.0, mandatory interactive Yubikey auth, and `deadman` USB kill switch.
  - **Isolation & Threat Prevention**: Bus-level USBGuard, default-drop `nftables`, AppArmor, Fail2ban, and ClamAV scans.
  - **Runtime Secrets**: Git-encrypted Age/SOPS decrypted at activation time (`sops-nix`).
  - **Auditing & Compliance**: Auditd, OpenSCAP tooling, and FIPS 140-3 validated crypto.
- **Hybrid Infrastructure & Orchestration**:
  - Multi-host infrastructure managed via Terraform on GCP, NextDNS, and Cloudflare.
  - Interactive remote deployment & re-installation via `deploy-host` and `nixos-anywhere` with Disko partitioning, `gum` UI, automatic SSH/Age host key staging into `/persist`, NetworkManager connection profile transfer, SOPS U2F key management, and SOPS secret validation.
  - Live installer ISO (`infector`) built with automated random root passwords, TTY QR code output, and TUI image burning (`burn-infector` with Caligula).
  - Journald logs ship to GCP Cloud Logging via a Vector agent.
  - Automated systemd cloud backups to GCS buckets.
  - Private Harmonia binary cache for faster Nix deployments.
  - Self-hosted GitHub Actions runner orchestration on NixOS.
  - Host network topology generated natively via `nix-topology`.
  - Support for OIDC/OAuth2 backed by Tailscale identities for SSO across all services.
- **Desktop Environments & Utilities**:
  - Wayland-native GNOME desktop experience.
  - Gaming & HTPC consoles with SteamOS (`steamdeck` and `steammachine`) via Jovian-NixOS.
  - Custom desktop tooling: Sherlock launcher and solar-based automatic light/dark theme switcher.
  - Containerized Android apps via Waydroid alongside Docker and Flatpak support.
- **Declarative Self-Hosted Services**:
  - Media & Home Automation: Home Assistant, Frigate (AI NVR), Jellyfin, BitMagnet, and Transmission.
  - Productivity & Knowledge: Immich (photo management), SilverBullet, and OnlyOffice DocumentServer.
  - Infrastructure & Monitoring: Beszel metrics hub/agent and secure access over Tailnet VPN.

## Documentation

Operational procedural guides in [`docs/`](docs/):

- [Remote Deployments & ISO Burning (`deploy-host` & `burn-infector`)](docs/deployments.md)
- [SOPS Secret Management & Host Onboarding](docs/secrets.md)
- [Cloud Infrastructure Management (`terraform` & `secretspec`)](docs/infrastructure.md)
- [USBGuard Device Discovery & Whitelisting](docs/usbguard.md)
- [YubiKey PAM, GPG Smartcard & SSH Operations](docs/yubikey.md)
- [AppArmor Status Inspection & Denial Debugging](docs/apparmor.md)
- [Nix Store Maintenance, Garbage Collection & Diffs](docs/maintenance.md)
- [GCP Bucket Backups & Restore Operations Guide](docs/gcp-backups.md)
