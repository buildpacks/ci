terraform {
  backend "remote" {
    organization = "buildpacksio"

    workspaces {
      name = "gh-runner-ubuntu-arm64"
    }
  }

  required_providers {
    equinix = {
      source  = "equinix/equinix"
    }
  }
  required_version = ">= 0.13"
}
