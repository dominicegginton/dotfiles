# SOPS Secret Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets. Secrets are encrypted with host Age keys and the GPG master key.

## 1. Edit Secret Files

To edit encrypted secret files:

```bash
# Edit global secrets
sops secrets/global.yaml

# Edit host-specific secrets
sops secrets/hosts/ghost-gs60.yaml
```

## 2. Add a New Host Age Key

To add a new host to `.sops.yaml`:

1. **Get the Age Key**:
   - The `deploy-host` script makes the key and shows the public Age key (`age1...`).
   - To get the Age key manually from an existing host public key:
     ```bash
     ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
     ```

2. **Update `.sops.yaml`**:
   Add the host key and creation rules to `.sops.yaml`:
   ```yaml
   keys:
     - &dom_key C11BEB9007709C34FABBB5314C79CE4F82847A9F
     - &my_new_host age1...

   creation_rules:
     - path_regex: secrets/global\.yaml$
       key_groups:
         - pgp: [ *dom_key ]
           age: [ *ghost_gs60, *my_new_host ]

     - path_regex: secrets/hosts/my-new-host\.yaml$
       key_groups:
         - pgp: [ *dom_key ]
           age: [ *my_new_host ]
   ```

3. **Update Secret Files**:
   Re-encrypt the secret files so the new host can decrypt them:
   ```bash
   sops updatekeys secrets/global.yaml
   ```

## 3. Creating Host-Specific Secret Files

To create a new host-specific secret file:

```bash
sops secrets/hosts/my-new-host.yaml
```

Define any host-specific service credentials (e.g. Immich API keys, Frigate tokens) inside the editor and save.
