module "gcp_infrastructure" {
  project_id         = var.gcp_project_id
  backend_file_path  = path.module
  billing_account_id = var.gcp_billing_account_id
  source             = "./modules/gcp-infrastructure"
}
