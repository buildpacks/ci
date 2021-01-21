variable "METAL_AUTH_TOKEN" {
  type        = string
  description = "Auth Token for Equinix Metal"
  sensitive   = true
}

variable "METAL_PROJECT_ID" {
  type        = string
  description = "Equinix Metal Project GUID"
}

variable "GH_TOKEN" {
  type        = string
  description = "GitHub personal access token."
  sensitive   = false
}

variable "GH_RUNNER_VERSION" {
  type        = string
  description = "Version of action runner to install"
  default     = "2.275.1"
}
