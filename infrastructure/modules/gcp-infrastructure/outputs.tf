output "terraform_backend_bucket" {
  description = "GCS Bucket name for Terraform remote backend"
  value       = google_storage_bucket.terraform_remote_backend.name
}

output "dominicegginton_bucket" {
  description = "GCS Bucket name for dominicegginton"
  value       = google_storage_bucket.dominicegginton.name
}

output "silverbullet_data_bucket" {
  description = "GCS Bucket name for SilverBullet data"
  value       = google_storage_bucket.silverbullet_data.name
}

output "immich_data_bucket" {
  description = "GCS Bucket name for Immich data"
  value       = google_storage_bucket.immich_data.name
}

output "frigate_data_bucket" {
  description = "GCS Bucket name for Frigate data"
  value       = google_storage_bucket.frigate_data.name
}

output "immich_backup_bucket" {
  description = "GCS Bucket name for Immich backups"
  value       = google_storage_bucket.immich_backup.name
}

output "immich_backup_service_account" {
  description = "Service account email for Immich backups"
  value       = google_service_account.immich_backup.email
}

output "silverbullet_backup_bucket" {
  description = "GCS Bucket name for Silverbullet backups"
  value       = google_storage_bucket.silverbullet_backup.name
}

output "silverbullet_backup_service_account" {
  description = "Service account email for Silverbullet backups"
  value       = google_service_account.silverbullet_backup.email
}

output "frigate_backup_bucket" {
  description = "GCS Bucket name for Frigate backups"
  value       = google_storage_bucket.frigate_backup.name
}

output "frigate_backup_service_account" {
  description = "Service account email for Frigate backups"
  value       = google_service_account.frigate_backup.email
}

output "project_id" {
  description = "GCP Project ID"
  value       = google_project_service.iam.project
}

output "secretmanager_service" {
  description = "Secret Manager service resource"
  value       = google_project_service.secretmanager
}
