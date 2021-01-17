# =====
# Tekton
# =====

data "kubectl_file_documents" "tekton_manifests" {
  content = file("${path.module}/assets/tekton-0.18.1.yaml")
}

resource "kubectl_manifest" "tekton" {
  count            = length(data.kubectl_file_documents.tekton_manifests.documents)
  yaml_body        = element(data.kubectl_file_documents.tekton_manifests.documents, count.index)
  wait             = true
  wait_for_rollout = true
}

# =====
# Dashboard
# =====

data "kubectl_file_documents" "dashboard_manifests" {
  content = file("${path.module}/assets/dashboard-0.11.1.yaml")
}

resource "kubectl_manifest" "dashboard" {
  count      = length(data.kubectl_file_documents.dashboard_manifests.documents)
  yaml_body  = element(data.kubectl_file_documents.dashboard_manifests.documents, count.index)
  depends_on = [kubectl_manifest.tekton]
}

# =====
# Tasks
# =====

variable "buildpacks_version" {
  default     = "0.2"
  description = "buildpacks task version"
}

data "http" "buildpacks_manifests" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/master/task/buildpacks/${var.buildpacks_version}/buildpacks.yaml"
}

resource "kubectl_manifest" "buildpacks" {
  yaml_body  = data.http.buildpacks_manifests.body
  depends_on = [kubectl_manifest.tekton]
}
