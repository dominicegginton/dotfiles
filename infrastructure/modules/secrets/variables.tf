
###############################
# Input variable: dom_user_password
#
# The password for the 'dom' user account. This should be provided securely.
# Marked as sensitive to avoid accidental exposure.
###############################
variable "dom_user_password" {
  description = "Password for dom's user account"
  type        = string
  sensitive   = true
  default     = null
}

###############################
# Input variable: project_id
#
# The GCP Project ID where resources will be created.
###############################
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

###############################
# Input variable: secretmanager_service
#
# Used to ensure the Secret Manager API is enabled before creating secrets.
###############################
variable "secretmanager_service" {
  description = "Secret Manager service dependency"
}

