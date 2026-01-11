variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "github_actions_service_account" {
  description = "GitHub Actions service account email"
  type        = string
}

variable "secretmanager_service" {
  description = "Secret Manager service dependency"
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
  default     = null
}

variable "tailscale_api_key" {
  description = "Tailscale API Key"
  type        = string
  sensitive   = true
  default     = null
}

variable "tailscale_auth_key" {
  description = "Tailscale Auth Key for connecting devices"
  type        = string
  sensitive   = true
  default     = null
}
