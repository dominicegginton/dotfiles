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
    address            = data.nextdns_setup_endpoint.ribble.ipv6[0]
    use_with_exit_node = true
  }
  nameservers {
    address            = data.nextdns_setup_endpoint.ribble.ipv6[1]
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

  lifecycle {
    ignore_changes = [gcs_credentials]
  }
}

data "tailscale_users" "all-users" {}
