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
  token = var.github_token
}

module "gcp_infrastructure" {
  source = "./modules/gcp-infrastructure"

  project_id        = var.gcp_project_id
  github_owner      = "dominicegginton"
  backend_file_path = path.module
}

module "secrets" {
  source = "./modules/secrets"

  project_id                     = var.gcp_project_id
  github_actions_service_account = module.gcp_infrastructure.service_account_email
  secretmanager_service          = module.gcp_infrastructure.secretmanager_service
  github_token                   = var.github_token
  tailscale_api_key              = var.tailscale_api_key
  tailscale_auth_key             = var.tailscale_auth_key
}

data "google_secret_manager_secret_version" "tailscale_api_key" {
  secret  = module.secrets.tailscale_api_key_secret_id
  project = var.gcp_project_id
}

data "google_secret_manager_secret_version" "tailscale_auth_key" {
  secret  = module.secrets.tailscale_auth_key_secret_id
  project = var.gcp_project_id
}

provider "tailscale" {
  api_key = data.google_secret_manager_secret_version.tailscale_api_key.secret_data
  tailnet = "dominic.egginton@gmail.com"
}

module "github_actions" {
  source = "./modules/github-actions"

  repository_name            = "dotfiles"
  workload_identity_provider = module.gcp_infrastructure.workload_identity_provider
  service_account_email      = module.gcp_infrastructure.service_account_email
  project_id                 = module.gcp_infrastructure.project_id
}

module "tailscale" {
  source = "./modules/tailscale"
}
