variable "tekton_version" {
  default     = "0.18.1"
  description = "tekton version"
}

variable "tekton_dashboard_version" {
  default     = "0.11.1"
  description = "tekton dashboard version"
}

data "http" "tekton_manifests" {
  url = "https://storage.googleapis.com/tekton-releases/pipeline/previous/v${var.tekton_version}/release.yaml"
}

data "kubectl_file_documents" "tekton_manifests" {
  content = data.http.tekton_manifests.body
}

resource "kubectl_manifest" "tekton" {
  count     = length(data.kubectl_file_documents.tekton_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.tekton_manifests.documents, count.index)
}

data "http" "tekton_dashboard_manifests" {
  url = "https://storage.googleapis.com/tekton-releases/dashboard/previous/v${var.tekton_dashboard_version}/tekton-dashboard-release.yaml"
}

data "kubectl_file_documents" "tekton_dashboard_manifests" {
  content = data.http.tekton_dashboard_manifests.body
}

resource "kubectl_manifest" "tekton_dashboard" {
  count     = length(data.kubectl_file_documents.tekton_dashboard_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.tekton_dashboard_manifests.documents, count.index)

  depends_on = [kubectl_manifest.tekton]
}
