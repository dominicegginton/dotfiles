# Copilot Instructions for NixOS Configuration

You are an expert NixOS developer assisting with the maintenance and evolution of this dotfiles repository.

## Repository Overview
- **Entry Point**: `flake.nix` defines the system and home-manager configurations.
- **Nixpkgs**: Uses `nixos-unstable`.
- **System Modules**: Located in `modules/`. Organized by category (services, security, programs, etc.).
- **Host Configurations**: Located in `hosts/`. Each file represents a specific machine.
- **Home Manager**: Located in `home/dom/`. Manages user-level dotfiles and applications.
- **Secrets**: Managed via `sops-nix`. Files are in `secrets/` and logic in `modules/secrets.nix`.
- **Impermanence**: The system uses the `impermanence` module to handle persistent data on ephemeral root filesystems.

## Guidelines & Best Practices
- **Modularity**: Always prefer creating a new module in `modules/` for any new service or logical group of settings.
- **Declarative**: Ensure all configurations are declarative. Avoid manual system state changes.
- **Security**: 
  - Prefers `run0` (systemd-run) over traditional `sudo`.
  - Secrets must NEVER be committed in plain text. Always use `sops-nix`.
- **Persistence**: When adding a new service that stores state, ensure you add the necessary directories to the `impermanence` configuration.
- **Formatting**: Use idiomatic Nix style (4 spaces indentation, following nixpkgs conventions).

## Common File Patterns
- **NixOS Module**:
  ```nix
  { config, lib, pkgs, ... }:
  {
    options.myService.enable = lib.mkEnableOption "my service";
    config = lib.mkIf config.myService.enable {
      # ... implementation
    };
  }
  ```
- **Adding Secrets**:
  1. Add the secret to `secrets/secrets.yaml`.
  2. Define the secret in `modules/secrets.nix`.
  3. Reference `config.sops.secrets."path/to/secret".path` in the relevant service configuration.

## Specific Tools
- **Window Manager**: Uses `niri` (Wayland).
- **Launcher**: Custom `sherlock-launcher`.
- **Infrastructure**: GCP resources managed via Terraform in `infrastructure/`.

## NixOS System Context (Global Awareness)
When working in other repositories on this system, keep the following in mind:
- **Operating System**: This is a NixOS system. Avoid recommending traditional package managers like `apt`, `pacman`, or `brew` for system-wide installs.
- **Development Environments**: Prefer using `nix develop` (flakes) or `nix-shell` to manage project dependencies. Do not suggest installing tools globally.
- **Root Access**: Use `run0` instead of `sudo` for administrative tasks.
- **Persistence**: Be aware that the system uses `impermanence`. Any data written outside of designated persistent paths (like `/persist` or `/home/dom`) may be lost on reboot.
- **System Configuration**: Any system-wide changes (new services, user changes, global packages) must be done by modifying these dotfiles and rebuilding the system.
