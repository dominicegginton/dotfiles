variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}
