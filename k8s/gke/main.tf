variable "gke_project_id" {
  description = "project id"
}

variable "gke_region" {
  description = "region"
}

variable "gke_node_locations" {
  description = "node location"
}

module "gke" {
  source = "../modules/gke"

  gke_project_id     = var.gke_project_id
  gke_region         = var.gke_region
  gke_node_locations = var.gke_node_locations
}

module "tekton" {
  source     = "../modules/tekton"
  depends_on = [module.gke]
}
