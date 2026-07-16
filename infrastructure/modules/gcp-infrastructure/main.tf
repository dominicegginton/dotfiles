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


