# YubiKey and GPG Operations

This document describes how to manage YubiKey devices, GPG smartcard operations, SSH keys, and PIN codes.

## 1. YubiKey PAM Authentication (`u2f_keys`)

You can manage YubiKey U2F keys with SOPS secrets (`sops-nix`). The decrypted keys are stored at `/home/dom/.config/Yubico/u2f_keys`.

### Add a New YubiKey Device

To register a new YubiKey for login and `run0` elevation:

```bash
# Insert the YubiKey and make the U2F key mapping string
pamu2fcfg -u dom
```

### Update SOPS Secrets

1. Show your current key string:
   ```bash
   cat ~/.config/Yubico/u2f_keys
   ```
2. Open global SOPS secrets:
   ```bash
   sops secrets/global.yaml
   ```
3. Add the key mapping under `users.dom.u2f_keys`:
   ```yaml
   users:
     dom:
       password: ENC[...]
       u2f_keys: |
         dom:v38A...==,f9B2...==,es256,+presence
   ```

## 2. GPG Smartcard Operations

GPG smartcard support uses the `pcscd` service and the `gpg-agent` program.

### Show Smartcard Status

```bash
# Show GPG smartcard data
gpg --card-status

# Show OpenPGP data with YubiKey Manager
ykman openpgp info
```

### Import GPG Keys on a New Host

To use your GPG keys on a new computer:

```bash
# 1. Import your public GPG key from GitHub
curl -s https://github.com/dominicegginton.gpg | gpg --import

# 2. Connect the GPG keys to the YubiKey
gpg --card-status

# 3. Set the key trust level to ultimate
gpg --edit-key C11BEB9007709C34FABBB5314C79CE4F82847A9F
# In the GPG prompt:
# > trust
# > 5 (ultimate)
# > y
# > quit
```

## 3. SSH Authentication with GPG

You can use your GPG key on the YubiKey for SSH authentication:

```bash
# Start GPG agent and set the SSH socket variable
gpgconf --launch gpg-agent
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# Show public keys in the SSH agent
ssh-add -l
```

## 4. Change Smartcard PINs

To change the User PIN (default: `123456`) or Admin PIN (default: `12345678`):

```bash
# Change PIN codes with YubiKey Manager
ykman openpgp access change-pin

# Change PIN codes with GPG
gpg --card-edit
# In GPG prompt:
# > admin
# > passwd
```

## 5. Lock Session on YubiKey Removal

A `udev` rule locks your session when you remove the YubiKey from the computer.

- **Trusted Network**: The system does not lock the session if the computer is connected to your home Wi-Fi network.
