data "tailscale_device" "latitude-7390" {
  name = "latitude-7390.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "latitude-7390" {
  device_id  = data.tailscale_device.latitude-7390.node_id
  authorized = true
}

resource "tailscale_device_tags" "latitude-7390" {
  device_id  = data.tailscale_device.latitude-7390.node_id
  tags       = ["tag:device-latitude-7390"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "ghost-gs60" {
  name = "ghost-gs60.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "ghost-gs60" {
  device_id  = data.tailscale_device.ghost-gs60.node_id
  authorized = true
}

resource "tailscale_device_tags" "ghost-gs60" {
  device_id  = data.tailscale_device.ghost-gs60.node_id
  tags       = ["tag:device-ghost-gs60"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "steamdeck" {
  name = "steamdeck.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "steamdeck" {
  device_id  = data.tailscale_device.steamdeck.node_id
  authorized = true
}

resource "tailscale_device_tags" "steamdeck" {
  device_id  = data.tailscale_device.steamdeck.node_id
  tags       = ["tag:device-steamdeck"]
  depends_on = [tailscale_acl.acl]
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
  device_id  = data.tailscale_device.doms-pixel-9.node_id
  tags       = []
  depends_on = [tailscale_acl.acl]
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
  device_id  = data.tailscale_device.beszel.node_id
  tags       = ["tag:service-beszel"]
  depends_on = [tailscale_acl.acl]
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
  device_id  = data.tailscale_device.frigate.node_id
  tags       = ["tag:service-frigate"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "idp" {
  name = "idp.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "idp" {
  device_id  = data.tailscale_device.idp.node_id
  authorized = true
}

resource "tailscale_device_tags" "idp" {
  device_id  = data.tailscale_device.idp.node_id
  tags       = ["tag:service-idp"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "immich" {
  name = "immich.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "immich" {
  device_id  = data.tailscale_device.immich.node_id
  authorized = true
}

resource "tailscale_device_tags" "immich" {
  device_id  = data.tailscale_device.immich.node_id
  tags       = ["tag:service-immich"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "jellyfin" {
  name = "jellyfin.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "jellyfin" {
  device_id  = data.tailscale_device.jellyfin.node_id
  authorized = true
}

resource "tailscale_device_tags" "jellyfin" {
  device_id  = data.tailscale_device.jellyfin.node_id
  tags       = ["tag:service-jellyfin"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "silverbullet" {
  name = "silverbullet.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "silverbullet" {
  device_id  = data.tailscale_device.silverbullet.node_id
  authorized = true
}

resource "tailscale_device_tags" "silverbullet" {
  device_id  = data.tailscale_device.silverbullet.node_id
  tags       = ["tag:service-silverbullet"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "transmission" {
  name = "transmission.soay-puffin.ts.net"
}

resource "tailscale_device_authorization" "transmission" {
  device_id  = data.tailscale_device.transmission.node_id
  authorized = true
}

resource "tailscale_device_tags" "transmission" {
  device_id  = data.tailscale_device.transmission.node_id
  tags       = ["tag:service-transmission"]
  depends_on = [tailscale_acl.acl]
}

data "tailscale_device" "cache" {
  name     = "cache.soay-puffin.ts.net"
  wait_for = "10s"
}

resource "tailscale_device_authorization" "cache" {
  device_id  = data.tailscale_device.cache.node_id
  authorized = true
}

resource "tailscale_device_tags" "cache" {
  device_id  = data.tailscale_device.cache.node_id
  tags       = ["tag:service-cache"]
  depends_on = [tailscale_acl.acl]
}
