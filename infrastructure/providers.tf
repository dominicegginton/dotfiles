terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = ">= 0.17.0"
    }

    nextdns = {
      source  = "registry.terraform.io/carbans/nextdns"
      version = "0.2.2"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project                 = var.gcp_project_id # GCP project ID
  region                  = "europe-west2"     # GCP region
  user_project_override   = true
  billing_project         = var.gcp_project_id
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}

provider "nextdns" {
  api_key = var.nextdns_api_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
