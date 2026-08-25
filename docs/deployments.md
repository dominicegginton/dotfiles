# Remote Deployments

You can run both `deploy-host` and `burn-infector` scripts in dry-run mode. The scripts show a summary and ask for your confirmation before they make system or disk changes.

## 1. Installer ISO (`burn-infector`)

To make the unattended live ISO installer (`.#infector-iso`) and write it to a USB drive:

```bash
# Make .#infector-iso and start Caligula disk imager
burn-infector

# Skip making the ISO and write the existing ./result ISO
burn-infector -s

# Run the command directly without confirmation
burn-infector -y
```

When you start the `infector` ISO on the remote machine, the screen shows:
- The random password for the `root` user
- The IP address and SSH target (`root@<IP>`)
- A QR code to scan with your device
- The pre-filled `deploy-host` command

## 2. Remote Host Deployment (`deploy-host`)

To install NixOS on a new machine or reinstall an existing host:

```bash
# Start interactive host deployment
deploy-host

# Reinstall an existing host
deploy-host ghost-gs60 root@192.168.1.50

# Deploy a new host and generate Age keys
deploy-host --mode new my-new-server root@10.0.0.100

# Get hardware configuration from target machine during install
deploy-host -g my-new-server root@10.0.0.100

# Run the command directly without confirmation
deploy-host -y ghost-gs60 root@192.168.1.50
```

## 3. Adding New Hosts and Hardware Configuration

To add a new machine:

1. **Hardware Scan**: Run `deploy-host -g`. The script runs `nixos-generate-config` on the remote machine and copies `./hosts/<hostname>-hardware.nix` to your local repository.
2. **Import Hardware Configuration**: Import the new file in your `hosts/<hostname>.nix`:
   ```nix
   imports = [
     ./<hostname>-hardware.nix
   ];
   ```
3. **SOPS and Age Keys**: The `deploy-host` script makes an ED25519 host key and gets the public Age key (`ssh-to-age`). The script copies the keys to `/etc/ssh/` and `/persist/etc/ssh/`. Follow the screen instructions to add the key to `.sops.yaml` and run `sops updatekeys secrets/global.yaml`.
4. **Git Tracking**: Add the new files to Git so Nix can read them:
   ```bash
   git add hosts/<hostname>-hardware.nix hosts/<hostname>.nix .sops.yaml secrets/global.yaml
   git commit -m "feat(hosts): add configuration and hardware scan for <hostname>"
   ```
