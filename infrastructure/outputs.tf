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

output "immich_backup_key" {
  description = "GCP Service Account Key for Immich backup (base64 encoded)"
  value       = module.gcp_infrastructure.immich_backup_key
  sensitive   = true
}

output "silverbullet_backup_key" {
  description = "GCP Service Account Key for SilverBullet backup (base64 encoded)"
  value       = module.gcp_infrastructure.silverbullet_backup_key
  sensitive   = true
}

output "frigate_backup_key" {
  description = "GCP Service Account Key for Frigate backup (base64 encoded)"
  value       = module.gcp_infrastructure.frigate_backup_key
  sensitive   = true
}
