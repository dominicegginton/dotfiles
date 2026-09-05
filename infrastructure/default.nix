# infrastructure/default.nix
#
# Terranix root configuration for personal infrastructure.
# Evaluates declarative Nix infrastructure modules into Terraform JSON.

{ config, lib, ... }:

{
  options.infrastructure = {
    gcp = {
      projectId = lib.mkOption {
        type = lib.types.str;
        default = "dominicegginton-personal";
        description = "GCP Project ID";
      };

      region = lib.mkOption {
        type = lib.types.str;
        default = "europe-west2";
        description = "GCP Region";
      };

      billingAccountId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "";
        description = "GCP Billing Account ID";
      };

      backendBucket = lib.mkOption {
        type = lib.types.str;
        default = "66ea520add6c51fb-terraform-remote-backend";
        description = "GCS Remote Backend Bucket Name";
      };
    };

    tailscale = {
      tailnet = lib.mkOption {
        type = lib.types.str;
        default = "soay-puffin.ts.net";
        description = "Tailscale Tailnet domain name";
      };
    };

    cloudflare = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "dominicegginton.dev";
        description = "Primary Cloudflare domain zone";
      };
    };
  };

  imports = [
    ./gcp.nix
    ./tailscale.nix
    ./nextdns.nix
    ./cloudflare.nix
  ];

  config = {
    terraform = {
      backend.gcs = {
        bucket = config.infrastructure.gcp.backendBucket;
      };

      required_providers = {
        google = {
          source = "hashicorp/google";
          version = ">= 4.0.0";
        };

        random = {
          source = "hashicorp/random";
          version = ">= 3.0.0";
        };

        local = {
          source = "hashicorp/local";
          version = ">= 2.0.0";
        };

        tailscale = {
          source = "tailscale/tailscale";
          version = ">= 0.17.0";
        };

        nextdns = {
          source = "carbans/nextdns";
          version = "0.2.2";
        };

        cloudflare = {
          source = "cloudflare/cloudflare";
          version = ">= 4.0.0";
        };
      };
    };

    provider = {
      google = {
        project = config.infrastructure.gcp.projectId;
        region = config.infrastructure.gcp.region;
        user_project_override = true;
        billing_project = config.infrastructure.gcp.projectId;
      };

      tailscale = {
        api_key = "\${var.tailscale_api_key}";
        tailnet = "\${var.tailscale_tailnet}";
      };

      nextdns = {
        api_key = "\${var.nextdns_api_token}";
      };

      cloudflare = {
        api_token = "\${var.cloudflare_api_token}";
      };
    };

    variable = {
      gcp_project_id = {
        description = "GCP Project ID";
        type = "string";
        default = config.infrastructure.gcp.projectId;
      };

      gcp_billing_account_id = {
        description = "The GCP Billing Account ID";
        type = "string";
        default = config.infrastructure.gcp.billingAccountId;
        sensitive = true;
      };

      tailscale_api_key = {
        description = "The API key for Tailscale";
        type = "string";
        default = null;
        sensitive = true;
      };

      tailscale_tailnet = {
        description = "The Tailscale tailnet to connect to";
        type = "string";
        default = config.infrastructure.tailscale.tailnet;
        sensitive = true;
      };

      nextdns_api_token = {
        description = "The NextDNS API Token";
        type = "string";
        default = null;
        sensitive = true;
      };

      nextdns_profile_ribble = {
        description = "The NextDNS Profile ID for Ribble";
        type = "string";
        default = null;
      };

      nextdns_profile_quandon = {
        description = "The NextDNS Profile ID for Quandon";
        type = "string";
        default = null;
      };

      cloudflare_api_token = {
        description = "The Cloudflare API Token";
        type = "string";
        default = null;
        sensitive = true;
      };

      cloudflare_account_id = {
        description = "The Cloudflare Account ID";
        type = "string";
        default = null;
        sensitive = true;
      };

      cloudflare_zone_id = {
        description = "The Cloudflare Zone ID for dominicegginton.dev";
        type = "string";
        default = null;
      };
    };
  };
}
