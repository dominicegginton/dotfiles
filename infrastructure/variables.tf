variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "dominicegginton-personal"
}

variable "gcp_billing_account_id" {
  description = "The GCP Billing Account ID"
  type        = string
  default     = null
  sensitive   = true
}

variable "tailscale_api_key" {
  description = "The API key for Tailscale"
  type        = string
  default     = null
  sensitive   = true
}

variable "tailscale_tailnet" {
  description = "The Tailscale tailnet to connect to"
  type        = string
  default     = null
  sensitive   = true
}

variable "nextdns_api_token" {
  description = "The NextDNS API Token"
  type        = string
  default     = null
  sensitive   = true
}

variable "nextdns_profile_ribble" {
  description = "The NextDNS Profile ID for Ribble"
  type        = string
  default     = null
}

variable "nextdns_profile_quandon" {
  description = "The NextDNS Profile ID for Quandon"
  type        = string
  default     = null
}