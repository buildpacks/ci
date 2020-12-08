variable "buildpacks_version" {
  default     = "0.2"
  description = "buildpacks task version"
}

data "http" "buildpacks_manifests" {
  url = "https://raw.githubusercontent.com/tektoncd/catalog/master/task/buildpacks/${var.buildpacks_version}/buildpacks.yaml"
}

data "kubectl_file_documents" "buildpacks_manifests" {
  content = data.http.buildpacks_manifests.body
}

resource "kubectl_manifest" "buildpacks" {
  count     = length(data.kubectl_file_documents.buildpacks_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.buildpacks_manifests.documents, count.index)

  depends_on = [kubectl_manifest.tekton]
}
