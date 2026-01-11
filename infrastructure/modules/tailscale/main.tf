terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
    }
  }
}

resource "tailscale_tailnet_settings" "main" {
  devices_approval_on           = var.devices_approval_on
  devices_auto_updates_on       = var.devices_auto_updates_on
  devices_key_duration_days     = var.devices_key_duration_days
  users_approval_on             = var.users_approval_on
  posture_identity_collection_on = var.posture_identity_collection_on
}
