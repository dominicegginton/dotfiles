variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token for managing repository secrets (only needed for local runs)"
  type        = string
  sensitive   = true
  default     = null
}
