# Windows LCOW Runner

## Usage

### Configuration

All secrets are managed via [Terraform Cloud](https://app.terraform.io/app/buildpacksio/workspaces).

The following script configures terraform CLI authentication against Terraform Cloud.

- [auth-terraform.sh](../scripts/auth-terraform.sh) 
    - _depends on: [`lpass`](https://github.com/lastpass/lastpass-cli)_

### Create

```shell
./../scripts/auth-terraform.sh
terraform init
terraform apply
```

- **Expected execution time:** ~35 minutes

##### Manual steps

1. Enable `C:\` drive sharing for volume mounting:
    - `Docker Desktop` -> `Settings` -> `Resources` -> `File Sharing`
    - Enter `C:\` -> Keypress `Enter`
    - Press `Apply & Restart`

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
