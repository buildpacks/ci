variable "dashboard_version" {
  default     = "2.0.5"
  description = "dashboard version"
}

data "http" "dashboard_manifests" {
  url = "https://raw.githubusercontent.com/kubernetes/dashboard/v${var.dashboard_version}/aio/deploy/recommended.yaml"
}

data "kubectl_file_documents" "dashboard_manifests" {
  content = data.http.dashboard_manifests.body
}

resource "kubectl_manifest" "dashboard" {
  count     = length(data.kubectl_file_documents.dashboard_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.dashboard_manifests.documents, count.index)
}

resource "kubectl_manifest" "dashboard_user" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
YAML
}

resource "kubectl_manifest" "dashboard_role" {
  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
YAML
}