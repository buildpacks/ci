# Linux ARM64 Runner

## Usage

### Configuration

All secrets are managed via [Terraform Cloud](https://app.terraform.io/app/buildpacksio/workspaces).

The following script configures terraform CLI authentication against Terraform Cloud.

- [auth-terraform.sh](../scripts/auth-terraform.sh) 
    - _depends on: [`op`](https://1password.com/downloads/command-line/)_

### Create

```shell
./../scripts/auth-terraform.sh
terraform init
terraform apply
```

- **Expected execution time:** ~30 minutes

### Info

```shell
# info (non-sensitive)
terraform output

# password (sensitive)
terraform output root_password
```

### Destroy

```shell
./../scripts/auth-terraform.sh
terraform init
terraform destroy
```
