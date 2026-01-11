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

output "workload_identity_provider" {
  description = "Workload Identity Provider resource name for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
  description = "Service account email for GitHub Actions"
  value       = google_service_account.github_actions.email
}

output "project_id" {
  description = "GCP Project ID"
  value       = google_project_service.iam.project
}

output "secretmanager_service" {
  description = "Secret Manager service resource"
  value       = google_project_service.secretmanager
}
