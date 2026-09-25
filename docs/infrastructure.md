# Cloud Infrastructure Management (`tofu` & `secretspec`)

GCP cloud infrastructure, Tailscale network configurations, NextDNS settings, and Cloudflare DNS records in `infrastructure/` are managed via OpenTofu wrappers (`secretspec`).

## 1. Prerequisites & Authentication

Before running infrastructure commands, ensure Google Cloud SDK authentication is active:

```bash
# Authenticate Google Cloud Application Default Credentials
gcloud auth application-default login
```

## 2. Infrastructure CLI Commands

When inside `nix develop`, the wrapped `tofu` binary automatically authenticates with GCP (if required) and injects runtime secrets via `secretspec`. You can run standard OpenTofu commands directly:

### Initializing Infrastructure

```bash
tofu init
```

### Planning Infrastructure Changes

```bash
tofu plan
```

### Applying Infrastructure Changes

```bash
tofu apply
```

## 3. Configuration Layout

To maintain a clean and modular infrastructure setup, configurations are separated into dedicated files:

- `providers.tf`: Provider setup and version mappings (Google, Tailscale, NextDNS, Cloudflare).
- `main.tf`: Core Google Cloud Platform infrastructure resources and modules.
- `tailscale.tf`: Global Tailnet configurations, ACLs, logging integrations, and settings.
- `tailscale_devices.tf`: Explicit Tailscale device listings, authorizations, and device tags.
- `nextdns.tf`: NextDNS profiles, policy details, and custom security/privacy configs.
- `cloudflare.tf`: Core Cloudflare zone parameters (`dominicegginton.dev`).
- `cloudflare_dns.tf`: Declarative Cloudflare DNS record configurations.

## 4. Declarative Nix-OpenTofu Helpers

This repository includes custom, highly-reproducible Nix library helpers, exposed via `lib.opentofu pkgs`.

### Helpers Available

1. **`writeOpenTofuVersions { package, providers }`**:
   Generates a fully declarative `versions.tf.json` and a matching `.terraform.lock.hcl` dependency lockfile for the specified OpenTofu package and plugins.

2. **`mkOpenTofuDerivation { name, package, providers, paths, validate }`**:
   Packages an OpenTofu root module directory (along with automatically-generated versions and lockfiles) as a compiled, reproducible Nix derivation. It wraps the resulting executable to always run within `-chdir` of the immutable build path and securely manages its state directory (`TF_DATA_DIR`).

### Usage Example

You can use these helpers in a package definition or development shell:

```nix
let
  tfHelpers = pkgs.lib.opentofu pkgs;

  myInfra = tfHelpers.mkOpenTofuDerivation {
    name = "personal-infra";
    package = pkgs.opentofu;
    providers = [ "google" "tailscale" "cloudflare" ];
    paths = [ ./infrastructure ];
    validate = true;
  };
in
myInfra
```

## 5. Managing Tailscale ACLs

Tailscale access control policies are defined in `infrastructure/tailscale_acl.json`.

1. Edit policy definitions in `infrastructure/tailscale_acl.json`.
2. Run `tofu plan` to verify ACL changes.
3. Run `tofu apply` to update Tailscale network ACLs.
