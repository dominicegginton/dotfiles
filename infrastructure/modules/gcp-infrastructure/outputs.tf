output "terraform_backend_bucket" {
  description = "GCS Bucket name for Terraform remote backend"
  value       = google_storage_bucket.terraform_remote_backend.name
}

output "dominicegginton_bucket" {
  description = "GCS Bucket name for dominicegginton"
  value       = google_storage_bucket.dominicegginton.name
}

output "immich_backup_bucket" {
  description = "GCS Bucket name for Immich backup"
  value       = google_storage_bucket.immich_backup.name
}

output "immich_backup_key" {
  description = "GCP Service Account Key for Immich backup (base64 encoded)"
  value       = google_service_account_key.immich_backup.private_key
  sensitive   = true
}

output "silverbullet_backup_bucket" {
  description = "GCS Bucket name for SilverBullet backup"
  value       = google_storage_bucket.silverbullet_backup.name
}

output "silverbullet_backup_key" {
  description = "GCP Service Account Key for SilverBullet backup (base64 encoded)"
  value       = google_service_account_key.silverbullet_backup.private_key
  sensitive   = true
}

output "frigate_backup_bucket" {
  description = "GCS Bucket name for Frigate backup"
  value       = google_storage_bucket.frigate_backup.name
}

output "frigate_backup_key" {
  description = "GCP Service Account Key for Frigate backup (base64 encoded)"
  value       = google_service_account_key.frigate_backup.private_key
  sensitive   = true
}

output "immich_retention_policy" {
  value = google_storage_bucket.immich_backup.retention_policy
}

output "silverbullet_retention_policy" {
  value = google_storage_bucket.silverbullet_backup.retention_policy
}

output "tailscale_logs_bucket" {
  description = "GCS Bucket name for Tailscale logs"
  value       = google_storage_bucket.tailscale_logs.name
}

output "tailscale_logstream_key" {
  description = "GCP Service Account Key for Tailscale logstream (base64 encoded)"
  value       = google_service_account_key.tailscale_logstream.private_key
  sensitive   = true
}

output "frigate_retention_policy" {
  value = google_storage_bucket.frigate_backup.retention_policy
}

output "immich_backup_service_account" {
  description = "Service account email for Immich backups"
  value       = google_service_account.immich_backup.email
}

output "silverbullet_backup_service_account" {
  description = "Service account email for Silverbullet backups"
  value       = google_service_account.silverbullet_backup.email
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
