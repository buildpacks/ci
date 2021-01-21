

### Prerequisites

- GCP account access
- Configured (authenticated) `gcloud`
    - `brew cask install google-cloud-sdk`
    - `gcloud init`
        - Login and select `cncf-buildpacks-ci` project
    - `gcloud auth application-default login`
- `kubectl`
    - `brew install kubectl`
- `terraform`
    - `brew install terraform`


### Updates

_NOTE: Variables are stored in [`terraform.tfvars`](terraform.tfvars)_

```shell
terraform init
terraform apply
```

### Access

```shell bash
gcloud container clusters get-credentials $(terraform output kubernetes_cluster_name) --region $(terraform output region)
```

```shell fish
gcloud container clusters get-credentials (terraform output kubernetes_cluster_name) --region (terraform output region)
```

### Dashboards

```shell
kubectl proxy
```

- [k8s](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)
    - Get token: 
    ```
    kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
    ````
- [Tekton](http://localhost:8001/api/v1/namespaces/tekton-pipelines/services/tekton-dashboard:http/proxy/#/pipelineruns)