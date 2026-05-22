###############################
# Input variable: gcp_project_id
#
# The GCP Project ID where resources will be created.
###############################
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

###############################
# Input variable: dom_user_password
#
# The password for the 'dom' user account, passed securely to the secrets module.
# Marked as sensitive to avoid accidental exposure.
###############################
variable "dom_user_password" {
  description = "Password for dom's user account"
  type        = string
  sensitive   = true
}
