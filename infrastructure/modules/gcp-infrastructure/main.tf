resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"
}

resource "google_project_service" "iamcredentials" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"
}

resource "google_project_service" "billingbudgets" {
  project = var.project_id
  service = "billingbudgets.googleapis.com"
}

resource "random_id" "terraform_remote_backend" {
  byte_length = 8
}

resource "google_storage_bucket" "terraform_remote_backend" {
  name                        = "${random_id.terraform_remote_backend.hex}-terraform-remote-backend"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "local_file" "terraform_remote_backend" {
  file_permission = "0644"
  filename        = "${var.backend_file_path}/backend.tf"

  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.terraform_remote_backend.name}"
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
  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }
  retention_policy {
    retention_period = 2592000 # 30 days
    is_locked        = false # Keep unlocked so you can modify it later if needed
  }
}

resource "google_storage_bucket" "immich_backup" {
  name                        = "immich-backup-${random_id.terraform_remote_backend.hex}"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = 30
    }
  }
  soft_delete_policy {
    retention_duration_seconds = 604800
  }
  retention_policy {
    retention_period = 2592000
    is_locked        = false
  }
}

resource "google_service_account" "immich_backup" {
  account_id   = "immich-backup"
  display_name = "Immich Backup Service Account"
}

resource "google_service_account_key" "immich_backup" {
  service_account_id = google_service_account.immich_backup.name
}

resource "google_storage_bucket_iam_member" "immich_backup" {
  bucket = google_storage_bucket.immich_backup.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.immich_backup.email}"
}

resource "google_storage_bucket" "silverbullet_backup" {
  name                        = "silverbullet-backup-${random_id.terraform_remote_backend.hex}"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = 30
    }
  }
  soft_delete_policy {
    retention_duration_seconds = 604800
  }
  retention_policy {
    retention_period = 2592000
    is_locked        = false
  }
}

resource "google_service_account" "silverbullet_backup" {
  account_id   = "silverbullet-backup"
  display_name = "Silverbullet Backup Service Account"
}

resource "google_service_account_key" "silverbullet_backup" {
  service_account_id = google_service_account.silverbullet_backup.name
}

resource "google_storage_bucket_iam_member" "silverbullet_backup" {
  bucket = google_storage_bucket.silverbullet_backup.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.silverbullet_backup.email}"
}

resource "google_storage_bucket" "frigate_backup" {
  name                        = "frigate-backup-${random_id.terraform_remote_backend.hex}"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      days_since_noncurrent_time = 30
    }
  }
  soft_delete_policy {
    retention_duration_seconds = 604800
  }
  retention_policy {
    retention_period = 2592000
    is_locked        = false
  }
}

resource "google_service_account" "frigate_backup" {
  account_id   = "frigate-backup"
  display_name = "Frigate Backup Service Account"
}

resource "google_service_account_key" "frigate_backup" {
  service_account_id = google_service_account.frigate_backup.name
}

resource "google_storage_bucket_iam_member" "frigate_backup" {
  bucket = google_storage_bucket.frigate_backup.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.frigate_backup.email}"
}

resource "google_storage_bucket" "tailscale_logs" {
  name                        = "tailscale-logs-${random_id.terraform_remote_backend.hex}"
  location                    = "EUROPE-WEST2"
  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}


resource "google_service_account" "tailscale_logstream" {
  account_id   = "tailscale-logstream"
  display_name = "Tailscale Logstream Service Account"
}

resource "google_service_account_key" "tailscale_logstream" {
  service_account_id = google_service_account.tailscale_logstream.name
}

resource "google_storage_bucket_iam_member" "tailscale_logstream" {
  bucket = google_storage_bucket.tailscale_logs.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.tailscale_logstream.email}"
}



resource "google_service_account" "gcp_logging" {
  account_id   = "vector-gcp-logging"
  display_name = "Vector GCP Cloud Logging Service Account"
}

resource "google_service_account_key" "gcp_logging" {
  service_account_id = google_service_account.gcp_logging.name
}

resource "google_project_iam_member" "gcp_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gcp_logging.email}"
}

resource "google_secret_manager_secret" "tailscale_api_key" {
  secret_id = "secretspec-${var.project_id}-default-TF_VAR_tailscale_api_key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret" "tailscale_tailnet" {
  secret_id = "secretspec-${var.project_id}-default-TF_VAR_tailscale_tailnet"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

data "google_project" "current" {}

resource "google_billing_budget" "budget" {
  count           = var.billing_account_id != null ? 1 : 0
  billing_account = var.billing_account_id
  display_name    = "GCP Project Budget Alert"

  budget_filter {
    projects               = ["projects/${data.google_project.current.number}"]
    credit_types_treatment = "INCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = "GBP"
      units         = "10" # Default low threshold budget of £10/month
    }
  }

  threshold_rules {
    threshold_percent = 0.50 # Alert at 50% (£5)
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 0.90 # Alert at 90% (£9)
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.00 # Alert at 100% (£10)
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    # Forecast alert when on track to exceed monthly budget limit
    threshold_percent = 1.00 
    spend_basis       = "FORECASTED_SPEND"
  }

  # Removing empty all_updates_rule, as OpenTofu/GCP requires either
  # monitoring_notification_channels or pubsub_topic to be supplied when defined.
  # Email alerts to Billing Account Admins & Users are enabled by default anyway.

  depends_on = [google_project_service.billingbudgets]
}


