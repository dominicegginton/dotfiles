terraform {
  required_providers {
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
  project = var.gcp_project_id # GCP project ID
  region  = "europe-west2"     # GCP region
}

module "gcp_infrastructure" {
  project_id        = var.gcp_project_id
  backend_file_path = path.module
  source            = "./modules/gcp-infrastructure"
}
