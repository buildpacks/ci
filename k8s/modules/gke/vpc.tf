variable "gke_project_id" {
  description = "project id"
}

variable "gke_region" {
  description = "region"
}

provider "google" {
  project = var.gke_project_id
  region  = var.gke_region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.gke_project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.gke_project_id}-subnet"
  region        = var.gke_region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"

}

output "region" {
  value       = var.gke_region
  description = "region"
}
