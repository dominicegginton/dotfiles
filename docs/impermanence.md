# Modular Impermanence (`/persist`)

System root `/` is ephemeral on supported hosts (`steamdeck`, `steammachine`), rolling back to a clean state on every boot via Btrfs subvolumes.

## Configuration & Architecture

- **Toggle Option**: Managed per-host via `impermanence.enable = true;`.
- **Co-located Persistence**: Service and feature persistence definitions (`bluetooth`, `networking`, `flatpak`, `jovian`, `gnupg`, `yubikey`, etc.) are modularized directly inside their respective feature modules under `modules/`.
- **Core Persistence (`modules/impermanence.nix`)**: Retains machine identity, SSH host keys, logs, SSL certs, and user home directories (`Downloads`, `Documents`, `.ssh`, `.local/share/keyrings`, etc.).
