output "gcp_workload_identity_provider" {
  description = "Workload Identity Provider resource name for GitHub Actions"
  value       = module.gcp_infrastructure.workload_identity_provider
}

output "gcp_service_account" {
  description = "Service account email for GitHub Actions"
  value       = module.gcp_infrastructure.service_account_email
}

output "gcp_project_id" {
  description = "GCP Project ID"
  value       = module.gcp_infrastructure.project_id
}

output "terraform_backend_bucket" {
  description = "GCS Bucket name for Terraform remote backend"
  value       = module.gcp_infrastructure.terraform_backend_bucket
}

output "dominicegginton_bucket" {
  description = "GCS Bucket name for dominicegginton"
  value       = module.gcp_infrastructure.dominicegginton_bucket
}

output "silverbullet_data_bucket" {
  description = "GCS Bucket name for SilverBullet data"
  value       = module.gcp_infrastructure.silverbullet_data_bucket
}

output "immich_data_bucket" {
  description = "GCS Bucket name for Immich data"
  value       = module.gcp_infrastructure.immich_data_bucket
}

output "frigate_data_bucket" {
  description = "GCS Bucket name for Frigate data"
  value       = module.gcp_infrastructure.frigate_data_bucket
}
