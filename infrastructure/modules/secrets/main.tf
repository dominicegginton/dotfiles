resource "google_secret_manager_secret" "github_token" {
  project   = var.project_id
  secret_id = "github-token"

  replication {
    auto {}
  }

  depends_on = [var.secretmanager_service]
}
resource "google_secret_manager_secret_version" "github_token" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_token
}
resource "google_secret_manager_secret_iam_member" "github_actions_github_token" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.github_actions_service_account}"
}

resource "google_secret_manager_secret" "tailscale_api_key" {
  project   = var.project_id
  secret_id = "tailscale-api-key"

  replication {
    auto {}
  }

  depends_on = [var.secretmanager_service]
}
resource "google_secret_manager_secret_version" "tailscale_api_key" {
  secret      = google_secret_manager_secret.tailscale_api_key.id
  secret_data = var.tailscale_api_key
}
resource "google_secret_manager_secret_iam_member" "github_actions_tailscale_api_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.tailscale_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.github_actions_service_account}"
}

resource "google_secret_manager_secret" "tailscale_auth_key" {
  project   = var.project_id
  secret_id = "tailscale-auth-key"

  replication {
    auto {}
  }

  depends_on = [var.secretmanager_service]
}
resource "google_secret_manager_secret_version" "tailscale_auth_key" {
  secret      = google_secret_manager_secret.tailscale_auth_key.id
  secret_data = var.tailscale_auth_key
}
resource "google_secret_manager_secret_iam_member" "github_actions_tailscale_auth_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.tailscale_auth_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.github_actions_service_account}"
}

