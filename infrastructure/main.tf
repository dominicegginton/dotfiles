###############################
# Terraform Block
#
# Specifies required providers and their versions.
###############################
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

###############################
# Google Provider Block
#
# Configures the Google Cloud provider with project and region.
###############################
provider "google" {
  project = var.gcp_project_id # GCP project ID
  region  = "europe-west2"     # GCP region
}

###############################
# GCP Infrastructure Module
#
# Provisions core GCP resources (buckets, APIs, etc).
###############################
module "gcp_infrastructure" {
  project_id        = var.gcp_project_id
  backend_file_path = path.module
  source            = "./modules/gcp-infrastructure"
}

###############################
# Secrets Module
#
# Provisions secrets in Google Secret Manager, including dom's user password.
#
# Pass dom_user_password via CLI or environment for security.
###############################
module "secrets" {
  source                = "./modules/secrets"
  project_id            = var.gcp_project_id
  secretmanager_service = module.gcp_infrastructure.secretmanager_service
  dom_user_password     = var.dom_user_password # Pass this securely (do not hardcode)
}

