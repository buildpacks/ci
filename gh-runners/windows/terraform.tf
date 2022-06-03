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
      version = "3.2.2"
    }
  }
  required_version = ">= 0.13"
}
