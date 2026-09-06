# Remote Deployments

This repository has deployment workflows for host system installation and host maintenance.

The deployment scripts (`deploy-host` and `burn-infector`) have an interactive dry-run mode. This mode shows a summary and asks for confirmation before it changes system data or disk partitions.

For cloud infrastructure deployment (GCP, Tailscale ACLs, Cloudflare, NextDNS), see [docs/infrastructure.md](infrastructure.md).

## 1. Installer Media Configurations (`infector`)

The `infector` host profiles in `flake.nix` use `nixos-images` presets to build unattended installation media.

### A. Bootable Installer USB ISO (`infector-iso`)

Use this ISO to write a USB drive and boot physical target hardware locally.

```bash
# Build .#infector-iso and start Caligula TUI disk imager
burn-infector

# Skip rebuild and burn existing ./result ISO
burn-infector -s

# Build and burn directly without dry-run confirmation
burn-infector -y
```

When the target machine boots from the `infector` ISO, it starts a frame-buffered `network-status` screen:
- It creates a random `root` password.
- It shows the detected IP address and SSH target (`root@<IP>`).
- It shows a QR code with SSH connection details.
- It suggests the pre-filled `deploy-host` command.

### B. Network Boot Image (`infector-netboot`)

Use this image to boot target hardware over the network with PXE or iPXE.

```bash
# Build netboot kernel and initrd images
nix build .#infector-netboot
```

### C. In-Place Kexec Installer Tarball (`infector-kexec`)

Use this tarball to boot the NixOS installer directly on a running remote Linux machine over SSH.

```bash
# Build kexec installer tarball
nix build .#infector-kexec
```

---

## 2. Target Machine Installation Methods (`deploy-host`)

Use the `deploy-host` script to install NixOS on a remote host.

### Method A: USB Live Installer Deployment

1. Write the installer ISO to a USB flash drive with `burn-infector`.
2. Boot the target machine from the USB flash drive.
3. Record the target IP address on the screen (`root@<IP>`).
4. On your workstation, run this command:
   ```bash
   deploy-host --mode new my-host root@<IP>
   ```

### Method B: In-Place Linux or SteamOS Deployment (Without USB ISO)

You can install NixOS on a machine that runs Linux or SteamOS over SSH without a USB flash drive.

1. Enable SSH on the target machine:
   ```bash
   # On target machine (for example, Steam Deck Konsole):
   sudo systemctl enable --now sshd
   ```
2. Copy your SSH key to the target machine:
   ```bash
   ssh-copy-id root@<TARGET_IP>
   ```
3. On your workstation, run `deploy-host`:
   ```bash
   deploy-host --mode new steamdeck root@<TARGET_IP>
   ```
   The `nixos-anywhere` tool uploads the installer to RAM, boots the installer, formats the NVMe drive with Disko, and installs NixOS.

### Method C: Reinstall an Existing NixOS Host

When you reinstall an existing NixOS machine, keep the SSH host keys to avoid re-encryption of SOPS secrets.

```bash
# Reinstall existing host and keep host keys
deploy-host --mode reinstall ghost-gs60 root@192.168.1.50

# Or pass the key copy flag
deploy-host -c ghost-gs60 root@192.168.1.50
```

---

## 3. Active Host System Updates and Rebuilds

### A. Local Machine Rebuild

Rebuild and activate the local host configuration:

```bash
# Rebuild and switch local host configuration
run0 nixos-rebuild switch --flake .#<hostname>
```

### B. Remote Host Rebuild Over SSH

Rebuild and activate a remote host configuration:

```bash
# Rebuild and switch remote target host
nixos-rebuild switch --flake .#<hostname> --target-host root@<hostname-or-ip>
```

---

## 4. Add New Hosts and Create Hardware Configurations

Follow these steps to add a new host profile:

1. Run `deploy-host` with the `-g` flag to scan hardware during installation:
   ```bash
   deploy-host -g my-new-server root@10.0.0.100
   ```
   This saves `./hosts/<hostname>-hardware.nix` on your local workstation.
2. Import the hardware module in `hosts/<hostname>.nix`:
   ```nix
   imports = [
     ./<hostname>-hardware.nix
   ];
   ```
3. Add the generated Age key to `.sops.yaml` and update secret files:
   ```bash
   sops updatekeys secrets/global.yaml
   ```
4. Commit the new files to Git:
   ```bash
   git add hosts/<hostname>-hardware.nix hosts/<hostname>.nix .sops.yaml secrets/global.yaml
   git commit -m "feat(hosts): add configuration and hardware scan for <hostname>"
   ```

---

## 5. Post-Deployment Security and Verification

- **Impermanence (`/persist`)**: The root directory (`/`) is ephemeral on supported hosts. The system stores host SSH keys in `/etc/ssh/` and `/persist/etc/ssh/` to keep keys across reboots.
- **SSH Hardening**: The system disables root SSH login after installation (`PermitRootLogin=no`). Use user `dom` with SSH keys or a YubiKey to log in.
- **Admin Privileges**: Use `run0` instead of `sudo` to run administrative commands.
- **SOPS Secret Decryption**: Check secret activation after the initial boot:
  ```bash
  systemctl status sops-nix.service
  ```


