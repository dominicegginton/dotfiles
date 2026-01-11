output "github_token_secret_id" {
  value = google_secret_manager_secret.github_token.id
}

output "tailscale_api_key_secret_id" {
  value = google_secret_manager_secret.tailscale_api_key.id
}

output "tailscale_auth_key_secret_id" {
  value = google_secret_manager_secret.tailscale_auth_key.id
}
