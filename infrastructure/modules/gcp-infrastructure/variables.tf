variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "backend_file_path" {
  description = "Path where backend.tf should be written"
  type        = string
}

variable "billing_account_id" {
  description = "The GCP Billing Account ID"
  type        = string
  default     = null
}
