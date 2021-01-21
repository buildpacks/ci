# RHEL Runner

## Usage

### Configuration

The following `source`-able scripts below retrieve the required secrets from your LastPass account. [`lpass`](https://github.com/lastpass/lastpass-cli) is required.

- [auth-equinix.sh](../scripts/auth-equinix.sh)
- [auth-github.sh](../scripts/auth-github.sh)
- [auth-redhat.sh](../scripts/auth-redhat.sh)

### Create

```shell
source ../scripts/auth-equinix.sh
source ../scripts/auth-github.sh
source ../scripts/auth-redhat.sh
terraform init
terraform apply
```

- **Expected execution time:** 20 minutes

### Info

```shell
terraform output
```

### Destroy

```shell
source ../scripts/auth-equinix.sh
source ../scripts/auth-github.sh
source ../scripts/auth-redhat.sh
terraform init
terraform destroy
```
