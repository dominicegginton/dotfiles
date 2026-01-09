terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
    }

    github = {
      source  = "integrations/github"
      version = ">= 4.0.0"
    }

    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = "europe-west2"
}

provider "github" {
  owner = "dominicegginton"
  token = var.github_pat
}

resource "google_project_service" "iam" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"
}

resource "random_id" "terraform-remote-backend" {
  byte_length = 8
}

resource "google_storage_bucket" "terraform-remote-backend" {
  name                        = "${random_id.terraform-remote-backend.hex}-terraform-remote-backend"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "local_file" "terraform-remote-backend" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"

  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.terraform-remote-backend.name}"
    }
  }
  EOT
}

resource "google_storage_bucket" "dominicegginton" {
  name                        = "dominicegginton"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "silverbullet_data" {
  name                        = "silverbullet-data-${random_id.terraform-remote-backend.hex}"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "immich_data" {
  name                        = "immich-data-${random_id.terraform-remote-backend.hex}"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "frigate_data" {
  name                        = "frigate-data-${random_id.terraform-remote-backend.hex}"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_project_service" "iamcredentials" {
  project = var.gcp_project_id
  service = "iamcredentials.googleapis.com"
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"

  depends_on = [google_project_service.iamcredentials]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC identity pool provider for GitHub Actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner == 'dominicegginton'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "github_actions" {
  project      = var.gcp_project_id
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions workflows"
}

resource "google_service_account_iam_member" "github_actions_workload_identity" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.owner/dominicegginton"
}

resource "google_project_iam_member" "github_actions_storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_service_usage_admin" {
  project = var.gcp_project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_iam_workload_identity_pool_admin" {
  project = var.gcp_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_service_account_admin" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_actions_project_iam_admin" {
  project = var.gcp_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "github_actions_secret" "gcp_workload_identity_provider" {
  repository      = "dotfiles"
  secret_name     = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = google_iam_workload_identity_pool_provider.github.name
}

resource "github_actions_secret" "gcp_service_account" {
  repository      = "dotfiles"
  secret_name     = "GCP_SERVICE_ACCOUNT"
  plaintext_value = google_service_account.github_actions.email
}

resource "github_actions_secret" "gcp_project_id" {
  repository      = "dotfiles"
  secret_name     = "GCP_PROJECT_ID"
  plaintext_value = google_project_service.iam.project
}

resource "github_actions_secret" "github_pat" {
  repository      = "dotfiles"
  secret_name     = "GH_PAT"
  plaintext_value = var.github_pat
}

output "gcp_workload_identity_provider" {
  description = "Workload Identity Provider resource name for GitHub Actions"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "gcp_service_account" {
  description = "Service account email for GitHub Actions"
  value       = google_service_account.github_actions.email
}

output "gcp_project_id" {
  description = "GCP Project ID"
  value       = var.gcp_project_id
}

output "terraform_backend_bucket" {
  description = "GCS Bucket name for Terraform remote backend"
  value       = google_storage_bucket.terraform-remote-backend.name
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

