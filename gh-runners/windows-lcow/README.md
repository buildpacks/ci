# Windows LCOW Runner

## Usage

### Configuration

The following `source`-able scripts below retrieve the required secrets from your LastPass account. [`lpass`](https://github.com/lastpass/lastpass-cli) is required.

- [auth-equinix.sh](../scripts/auth-equinix.sh)
- [auth-github.sh](../scripts/auth-github.sh)

### Create

```shell
source ../scripts/auth-equinix.sh
source ../scripts/auth-github.sh
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

To view credentials for a runner, execute:

```shell
terraform output
```

The password for the machine is marked 'sensitive'. To view the password, you must explicitly request to view its contents:

```bash
terraform output root_password
```

### Destroy

```shell
source ../scripts/auth-equinix.sh
source ../scripts/auth-github.sh
terraform init
terraform destroy
```
