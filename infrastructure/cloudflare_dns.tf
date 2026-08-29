# Auto-generated DNS records from Cloudflare API

resource "cloudflare_dns_record" "apex_a_c627c996" {
  zone_id = var.cloudflare_zone_id
  name    = "dominicegginton.dev"
  type    = "A"
  content = "199.36.158.100"
  ttl     = 1
  proxied = true
  comment = "Firebase"
}

resource "cloudflare_dns_record" "www_apex_a_57eb3ee3" {
  zone_id = var.cloudflare_zone_id
  name    = "www.dominicegginton.dev"
  type    = "A"
  content = "199.36.158.100"
  ttl     = 1
  proxied = true
  comment = "Firebase"
}

resource "cloudflare_dns_record" "apex_mx_3bc8a442" {
  zone_id = var.cloudflare_zone_id
  name    = "dominicegginton.dev"
  type    = "MX"
  content = "route3.mx.cloudflare.net"
  ttl     = 1
  priority = 92
  proxied = false
}

resource "cloudflare_dns_record" "apex_mx_86bb5e93" {
  zone_id = var.cloudflare_zone_id
  name    = "dominicegginton.dev"
  type    = "MX"
  content = "route2.mx.cloudflare.net"
  ttl     = 1
  priority = 91
  proxied = false
}

resource "cloudflare_dns_record" "apex_mx_b57fff93" {
  zone_id = var.cloudflare_zone_id
  name    = "dominicegginton.dev"
  type    = "MX"
  content = "route1.mx.cloudflare.net"
  ttl     = 1
  priority = 33
  proxied = false
}

resource "cloudflare_dns_record" "cf2024_1_domainkey_apex_txt_674fb19b" {
  zone_id = var.cloudflare_zone_id
  name    = "cf2024-1._domainkey.dominicegginton.dev"
  type    = "TXT"
  content = "\"v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiweykoi+o48IOGuP7GR3X0MOExCUDY/BCRHoWBnh3rChl7WhdyCxW3jgq1daEjPPqoi7sJvdg5hEQVsgVRQP4DcnQDVjGMbASQtrY4WmB1VebF+RPJB2ECPsEDTpeiI5ZyUAwJaVX7r6bznU67g7LvFq35yIo4sdlmtZGV+i0H4cpYH9+3JJ78k\" \"m4KXwaf9xUJCWF6nxeD+qG6Fyruw1Qlbds2r85U9dkNDVAS3gioCvELryh1TxKGiVTkg4wqHTyHfWsp7KD3WQHYJn0RyfJJu6YEmL77zonn7p2SRMvTMP3ZEXibnC9gz3nnhR6wcYL8Q7zXypKTMD58bTixDSJwIDAQAB\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "discord_apex_txt_d087ef02" {
  zone_id = var.cloudflare_zone_id
  name    = "_discord.dominicegginton.dev"
  type    = "TXT"
  content = "\"dh=3c906a7b54763145faf924a3b5542390cbd3f109\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "dmarc_apex_txt_67f4a4c5" {
  zone_id = var.cloudflare_zone_id
  name    = "_dmarc.dominicegginton.dev"
  type    = "TXT"
  content = "v=DMARC1; p=reject; sp=reject; adkim=s; aspf=s; rua=mailto:290ed8f266a8446e869b16b262582586@dmarc-reports.cloudflare.net,mailto:dominic.egginton@gmail.com"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "wildcard_domainkey_apex_txt_a7bb20d8" {
  zone_id = var.cloudflare_zone_id
  name    = "*._domainkey.dominicegginton.dev"
  type    = "TXT"
  content = "v=DKIM1; p="
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "apex_txt_eb201ba6" {
  zone_id = var.cloudflare_zone_id
  name    = "dominicegginton.dev"
  type    = "TXT"
  content = "\"google-site-verification=S1BTH47J5buEQEAP9Y1y68xTm-0Qe8KMSygydP2U2-4\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "apex_txt_d2e973be" {
  zone_id = var.cloudflare_zone_id
  name    = "dominicegginton.dev"
  type    = "TXT"
  content = "\"v=spf1 include:_spf.mx.cloudflare.net ~all\""
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "apex_txt_0443df3f" {
  zone_id = var.cloudflare_zone_id
  name    = "dominicegginton.dev"
  type    = "TXT"
  content = "hosting-site=dominicegginton-dev"
  ttl     = 1
  proxied = false
}

