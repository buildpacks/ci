variable "METAL_AUTH_TOKEN" {
  type        = string
  description = "Auth Token for Equinix Metal"
  sensitive   = true
}

variable "METAL_PROJECT_ID" {
  type        = string
  description = "Equinix Metal Project GUID"
}

variable "RH_USERNAME" {
  type        = string
  description = "RedHat Username"
}

variable "RH_PASSWORD" {
  type        = string
  description = "RedHat Password"
  sensitive   = true
}

variable "RH_PULL_SECRET" {
  type        = string
  description = "RedHat Pull Secret"
  sensitive   = true
}

variable "GH_TOKEN" {
  type        = string
  description = "GitHub personal access token."
  sensitive   = true
}

variable "GH_OWNER" {
  type        = string
  description = "GitHub organization"
}

variable "GH_REPO" {
  type        = string
  description = "GitHub repo name"
}

variable "GH_RUNNER_VERSION" {
  type        = string
  description = "Version of action runner to install"
  default     = "2.275.1"
}
