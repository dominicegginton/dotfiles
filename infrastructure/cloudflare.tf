resource "cloudflare_zone" "domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "dominicegginton.dev"
}

# Import block to allow declarative importing of the existing Cloudflare zone
import {
  to = cloudflare_zone.domain
  id = var.cloudflare_zone_id
}
