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
  }
}

provider "google" {
  project = var.gcp_project_id # GCP project ID
  region  = "europe-west2"     # GCP region
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_tailnet
}

resource "tailscale_tailnet_settings" "sample_tailnet_settings" {
  acls_externally_managed_on                  = false
  devices_approval_on                         = true
  devices_auto_updates_on                     = true
  devices_key_duration_days                   = 5
  users_approval_on                           = true
  users_role_allowed_to_join_external_tailnet = "member"
  https_enabled                               = true
}

resource "tailscale_acl" "acl" {
  acl                        = file("${path.module}/tailscale_acl.json")
  overwrite_existing_content = true
}

resource "tailscale_dns_configuration" "sample_configuration" {
  nameservers {
    address            = "2a07:a8c0::cd:dfb8"
    use_with_exit_node = true
  }
  search_paths       = []
  override_local_dns = true
  magic_dns          = true
}

module "gcp_infrastructure" {
  project_id        = var.gcp_project_id
  backend_file_path = path.module
  source            = "./modules/gcp-infrastructure"
}
