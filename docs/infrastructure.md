# Cloud Infrastructure Management (`terraform` & `secretspec`)

GCP cloud infrastructure, Tailscale network configurations, NextDNS settings, and Cloudflare DNS records in `infrastructure/` are managed via Terraform wrappers (`secretspec`).

## 1. Prerequisites & Authentication

Before running infrastructure commands, ensure Google Cloud SDK authentication is active:

```bash
# Authenticate Google Cloud Application Default Credentials
gcloud auth application-default login
```

## 2. Infrastructure CLI Commands

When inside `nix develop`, the wrapped `terraform` binary automatically authenticates with GCP (if required) and injects runtime secrets via `secretspec`. You can run standard `terraform` commands directly:

### Initializing Infrastructure

```bash
terraform init
```

### Planning Infrastructure Changes

```bash
terraform plan
```

### Applying Infrastructure Changes

```bash
terraform apply
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

## 4. Declarative Nix-Terraform Helpers

This repository includes custom, highly-reproducible Nix library helpers inspired by `nix-terraform`, exposed via `lib.terraform pkgs`. These allow you to build, package, and validate Terraform setups as immutable, declarative Nix derivations.

### Helpers Available:

1. **`writeTerraformVersions { package, providers }`**:
   Generates a fully declarative `versions.tf.json` and a matching `.terraform.lock.hcl` dependency lockfile for the specified Terraform package and plugins.
   
2. **`mkTerraformDerivation { name, package, providers, paths, validate }`**:
   Packages a Terraform root module directory (along with automatically-generated versions and lockfiles) as a compiled, reproducible Nix derivation. It wraps the resulting executable to always run within `-chdir` of the immutable build path and securely manages its state directory (`TF_DATA_DIR`).

### Usage Example:
You can use these helpers in a package definition or development shell:
```nix
let
  tfHelpers = pkgs.lib.terraform pkgs;
  
  myInfra = tfHelpers.mkTerraformDerivation {
    name = "personal-infra";
    package = pkgs.terraform;
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
2. Run `terraform plan` to verify ACL changes.
3. Run `terraform apply` to update Tailscale network ACLs.
