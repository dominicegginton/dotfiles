variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "dominicegginton"
}

variable "backend_file_path" {
  description = "Path where backend.tf should be written"
  type        = string
}
