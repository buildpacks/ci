## Environments

This setup is broken into various environments:

- [gke](gke) - Google Kubernetes Engine environment
- [local](local) - Local k8s environment (ie. [kind](https://kind.sigs.k8s.io/), Docker)

## Prerequisites

- `kubectl`
    - `brew install kubectl`
- `terraform`
    - `brew install terraform`

### GKE

- GCP account access
- Configured (authenticated) `gcloud`
    - `brew cask install google-cloud-sdk`
    - `gcloud init`
        - Login and select `cncf-buildpacks-ci` project
    - `gcloud auth application-default login`

## Updates

```shell
terraform -chdir=<ENV> init
terraform -chdir=<ENV> apply
```

## Access

### GKE

```shell bash
gcloud container clusters get-credentials $(terraform output kubernetes_cluster_name) --region $(terraform output region)
```

### Dashboards

```shell
kubectl proxy
```

- [Tekton](http://localhost:8001/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/#/pipelineruns)