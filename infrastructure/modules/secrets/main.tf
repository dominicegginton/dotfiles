
###############################
# Google Secret Manager Secret for dom's user password
#
# This resource creates a secret in Google Secret Manager to store the password for the 'dom' user.
# The secret is named 'user-dom-password' for clarity and convention.
###############################
resource "google_secret_manager_secret" "dom_user_password" {
	project   = var.project_id # GCP project where the secret will be created
	secret_id = "user-dom-password" # Secret name in GCP Secret Manager

	replication {
		auto {} # Use automatic replication
	}

	depends_on = [var.secretmanager_service] # Ensure Secret Manager API is enabled
}

###############################
# Secret Version for dom's user password
#
# This resource adds the actual password value to the secret created above.
# The value is provided via the 'dom_user_password' variable.
###############################
resource "google_secret_manager_secret_version" "dom_user_password" {
	secret      = google_secret_manager_secret.dom_user_password.id # Reference to the secret
	secret_data = var.dom_user_password # The password value (sensitive)
}


