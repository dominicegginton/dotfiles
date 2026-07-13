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

resource "tailscale_contacts" "contacts" {
  account {
    email = "dominic.egginton@gmail.com"
  }

  support {
    email = "dominic.egginton@gmail.com"
  }

  security {
    email = "dominic.egginton@gmail.com"
  }
}

resource "tailscale_tailnet_settings" "settings" {
  acls_externally_managed_on                  = false
  devices_approval_on                         = true
  devices_auto_updates_on                     = true
  devices_key_duration_days                   = 5
  users_approval_on                           = true
  users_role_allowed_to_join_external_tailnet = "member"
  https_enabled                               = true
}

resource "tailscale_dns_configuration" "dns_configuration" {
  nameservers {
    address            = "2a07:a8c0::cd:dfb8"
    use_with_exit_node = true
  }
  search_paths       = []
  override_local_dns = true
  magic_dns          = true
}

resource "tailscale_acl" "acl" {
  acl                        = file("${path.root}/tailscale_acl.json")
  overwrite_existing_content = true
}

resource "tailscale_logstream_configuration" "gcs_logstream" {
  log_type         = "configuration"
  destination_type = "gcs"
  gcs_bucket       = module.gcp_infrastructure.tailscale_logs_bucket
  gcs_credentials  = base64decode(module.gcp_infrastructure.tailscale_logstream_key)
  gcs_scopes       = ["https://www.googleapis.com/auth/devstorage.read_write"]
}

data "tailscale_users" "all-users" {}

data "tailscale_device" "latitude-7390" {
  name = "latitude-7390.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "latitude-7390" {
  device_id  = data.tailscale_device.latitude-7390.node_id
  authorized = true
}

resource "tailscale_device_tags" "latitude-7390" {
  device_id = data.tailscale_device.latitude-7390.node_id
  tags      = ["tag:device-latitude-7390"]
}

data "tailscale_device" "ghost-gs60" {
  name = "ghost-gs60.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "ghost-gs60" {
  device_id  = data.tailscale_device.ghost-gs60.node_id
  authorized = true
}

resource "tailscale_device_tags" "ghost-gs60" {
  device_id = data.tailscale_device.ghost-gs60.node_id
  tags      = ["tag:device-ghost-gs60"]
}

data "tailscale_device" "steamdeck" {
  name = "steamdeck.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "steamdeck" {
  device_id  = data.tailscale_device.steamdeck.node_id
  authorized = true
}

resource "tailscale_device_tags" "steamdeck" {
  device_id = data.tailscale_device.steamdeck.node_id
  tags      = ["tag:device-steamdeck"]
}


data "tailscale_device" "doms-pixel-9" {
  name     = "doms-pixel-9.soay-puffin.ts.net"
  wait_for = "10s"
}

resource "tailscale_device_authorization" "doms-pixel-9" {
  device_id  = data.tailscale_device.doms-pixel-9.node_id
  authorized = true
}

resource "tailscale_device_tags" "doms-pixel-9" {
  device_id = data.tailscale_device.doms-pixel-9.node_id
  tags      = []
}

data "tailscale_device" "beszel" {
  name     = "beszel.soay-puffin.ts.net"
  wait_for = "10s"
}

resource "tailscale_device_authorization" "beszel" {
  device_id  = data.tailscale_device.beszel.node_id
  authorized = true
}

resource "tailscale_device_tags" "beszel" {
  device_id = data.tailscale_device.beszel.node_id
  tags      = ["tag:service-beszel"]
}

data "tailscale_device" "frigate" {
  name     = "frigate.soay-puffin.ts.net"
  wait_for = "10s"
}

resource "tailscale_device_authorization" "frigate" {
  device_id  = data.tailscale_device.frigate.node_id
  authorized = true
}

resource "tailscale_device_tags" "frigate" {
  device_id = data.tailscale_device.frigate.node_id
  tags      = ["tag:service-frigate"]
}

data "tailscale_device" "idp" {
  name = "idp.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "idp" {
  device_id  = data.tailscale_device.idp.node_id
  authorized = true
}

resource "tailscale_device_tags" "idp" {
  device_id = data.tailscale_device.idp.node_id
  tags      = ["tag:service-idp"]
}

data "tailscale_device" "immich" {
  name = "immich.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "immich" {
  device_id  = data.tailscale_device.immich.node_id
  authorized = true
}

resource "tailscale_device_tags" "immich" {
  device_id = data.tailscale_device.immich.node_id
  tags      = ["tag:service-immich"]
}

data "tailscale_device" "jellyfin" {
  name = "jellyfin.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "jellyfin" {
  device_id  = data.tailscale_device.jellyfin.node_id
  authorized = true
}

resource "tailscale_device_tags" "jellyfin" {
  device_id = data.tailscale_device.jellyfin.node_id
  tags      = ["tag:service-jellyfin"]
}

data "tailscale_device" "silverbullet" {
  name = "silverbullet.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "silverbullet" {
  device_id  = data.tailscale_device.silverbullet.node_id
  authorized = true
}

resource "tailscale_device_tags" "silverbullet" {
  device_id = data.tailscale_device.silverbullet.node_id
  tags      = ["tag:service-silverbullet"]
}

data "tailscale_device" "transmission" {
  name = "transmission.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "transmission" {
  device_id  = data.tailscale_device.transmission.node_id
  authorized = true
}

resource "tailscale_device_tags" "transmission" {
  device_id = data.tailscale_device.transmission.node_id
  tags      = ["tag:service-transmission"]
}

module "gcp_infrastructure" {
  project_id        = var.gcp_project_id
  backend_file_path = path.module
  source            = "./modules/gcp-infrastructure"
}
