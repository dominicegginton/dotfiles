###############################
# Output: dom_user_password_secret_id
#
# Exposes the resource ID of the dom user password secret for use in other modules.
###############################
output "dom_user_password_secret_id" {
  value = google_secret_manager_secret.dom_user_password.id
}
