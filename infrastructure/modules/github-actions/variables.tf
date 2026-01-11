variable "repository_name" {
  description = "GitHub repository name"
  type        = string
  default     = "dotfiles"
}

variable "workload_identity_provider" {
  description = "GCP Workload Identity Provider resource name"
  type        = string
}

variable "service_account_email" {
  description = "GCP Service Account email"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
