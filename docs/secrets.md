# SOPS Secret Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets. Secrets are encrypted with host Post-Quantum Age keys (`/persist/var/lib/sops-nix/key.txt`) and Dominic's Post-Quantum master Age key (`~/.config/sops/age/keys.txt`).

## 1. Edit Secret Files

To edit encrypted secret files:

```bash
# Set local master age key environment variable
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Edit global secrets
sops secrets/global.yaml

# Edit host-specific secrets
sops secrets/hosts/ghost-gs60.yaml
```

## 2. Add a New Host Post-Quantum Age Key

To add a new host to `.sops.yaml`:

1. **Generate the Post-Quantum Host Key**:
   Generate a new ML-KEM-768 + X25519 key pair for the new host:
   ```bash
   age-keygen -pq -o /tmp/my-new-host.key
   ```

2. **Get the Public Recipient**:
   ```bash
   age-keygen -y /tmp/my-new-host.key
   # Output: age1pq1...
   ```

3. **Update `.sops.yaml`**:
   Add the new host key and creation rules to `.sops.yaml`:

   ```yaml
   keys:
     - &dom_pq age1pq1...
     - &my_new_host_pq age1pq1...

   creation_rules:
     - path_regex: secrets/global\.yaml$
       key_groups:
         - age: [*dom_pq, *ghost_gs60_pq, *my_new_host_pq]

     - path_regex: secrets/hosts/my-new-host\.yaml$
       key_groups:
         - age: [*dom_pq, *my_new_host_pq]
   ```

4. **Update Secret Files**:
   Re-encrypt the secret files so the new host can decrypt them:
   ```bash
   sops updatekeys secrets/global.yaml
   ```

5. **Deploy the Host Private Key**:
   Install the private key on the target machine:
   ```bash
   run0 install -d -m 0700 /persist/var/lib/sops-nix
   run0 install -m 0400 /tmp/my-new-host.key /persist/var/lib/sops-nix/key.txt
   rm /tmp/my-new-host.key
   ```

## 3. Creating Host-Specific Secret Files

To create a new host-specific secret file:

```bash
sops secrets/hosts/my-new-host.yaml
```

Define any host-specific service credentials (e.g. Immich API keys, Frigate tokens) inside the editor and save.
