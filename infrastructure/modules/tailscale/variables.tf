variable "devices_approval_on" {
  description = "Require device approval"
  type        = bool
  default     = true
}

variable "devices_auto_updates_on" {
  description = "Enable automatic device updates"
  type        = bool
  default     = true
}

variable "devices_key_duration_days" {
  description = "Device key duration in days"
  type        = number
  default     = 180
}

variable "users_approval_on" {
  description = "Require user approval"
  type        = bool
  default     = true 
}

variable "posture_identity_collection_on" {
  description = "Enable posture identity collection"
  type        = bool
  default     = true
}
