variable "METAL_AUTH_TOKEN" {
  type        = string
  description = "Auth Token for Equinix Metal"
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
}

variable "RH_CRC_VERSION" {
  type        = string
  description = "RedHat CodeReady Containers version"
  default     = "latest"
}

variable "RH_PULL_SECRET" {
  type        = string
  description = "RedHat Pull Secret"
}

variable "GH_TOKEN" {
  type        = string
  description = "GitHub personal access token."
}

variable "GH_RUNNER_VERSION" {
  type        = string
  description = "Version of action runner to install"
  default     = "2.275.1"
}

variable "LOGIN_USERNAME" {
  type        = string
  description = "Login username"
}

variable "LOGIN_PASSWORD" {
  type        = string
  description = "Login password"
}
