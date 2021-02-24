terraform {
  backend "remote" {
    organization = "buildpacksio"

    workspaces {
      name = "windows"
    }
  }

  required_providers {
    metal = {
      source  = "equinix/metal"
      version = "1.0.0"
    }
  }
  required_version = ">= 0.13"
}
