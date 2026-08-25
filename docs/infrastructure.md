# Cloud Infrastructure Management (`opentofu` & `secretspec`)

GCP cloud infrastructure and Tailscale network configuration in `infrastructure/` are managed via OpenTofu wrappers (`secretspec`).

## 1. Prerequisites & Authentication

Before running infrastructure commands, ensure Google Cloud SDK authentication is active:

```bash
# Authenticate Google Cloud Application Default Credentials
gcloud auth application-default login
```

## 2. Infrastructure CLI Commands

Dedicated wrapper scripts in `shell.nix` invoke OpenTofu through `secretspec` to ensure GCP credentials and secrets are injected securely at runtime.

### Initializing Infrastructure
```bash
infrastructure-init
```

### Planning Infrastructure Changes
```bash
infrastructure-plan
```

### Applying Infrastructure Changes
```bash
infrastructure-apply
```

## 3. Managing Tailscale ACLs

Tailscale access control policies are defined in `infrastructure/tailscale_acl.json`.

1. Edit policy definitions in `infrastructure/tailscale_acl.json`.
2. Run `infrastructure-plan` to verify ACL changes.
3. Run `infrastructure-apply` to update Tailscale network ACLs.
