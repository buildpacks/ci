variable "METAL_PROJECT_ID" {
  type        = string
  description = "Equinix Metal Project GUID"
  sensitive   = true
}

variable "METAL_AUTH_TOKEN" {
  type        = string
  description = "Auth Token for Equinix Metal"
  sensitive   = true
}

variable "GH_OWNER" {
  type        = string
  default     = "buildpacks"
}

variable "GH_REPO" {
  type        = string
  default     = "lifecycle"
}

variable "GH_RUNNER_SHA256" {
  type        = string
  description = "SHA 256 of action runner to install"
  default     = "debe1cc9656963000a4fbdbb004f475ace5b84360ace2f7a191c1ccca6a16c00"
}

variable "GH_RUNNER_VERSION" {
  type        = string
  description = "Version of action runner to install"
  default     = "2.299.1"
}

variable "GH_RUNNER_REG_TOKEN" {
  type        = string
  description = "GitHub actions runner registration token (use instead of personal access token)."
  sensitive   = true
}

variable "GH_TOKEN" {
  type        = string
  description = "GitHub personal access token."
  sensitive   = true
}
