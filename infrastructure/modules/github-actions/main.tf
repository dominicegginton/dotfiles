resource "github_actions_secret" "gcp_workload_identity_provider" {
  repository      = var.repository_name
  secret_name     = "GCP_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = var.workload_identity_provider
}

resource "github_actions_secret" "gcp_service_account" {
  repository      = var.repository_name
  secret_name     = "GCP_SERVICE_ACCOUNT"
  plaintext_value = var.service_account_email
}

resource "github_actions_secret" "gcp_project_id" {
  repository      = var.repository_name
  secret_name     = "GCP_PROJECT_ID"
  plaintext_value = var.project_id
}
