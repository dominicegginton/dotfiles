terraform {
  required_providers {
    tailscale = {
      source = "tailscale/tailscale"
    }
  }
}

provider "google" {
  project = "dominicegginton-personal"
  region  = "europe-west2"
}

provider "tailscale" {}

provider "random" {}

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
