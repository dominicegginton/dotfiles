variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
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
}