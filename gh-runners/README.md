# Usage

## Configuration

The following `source`-able scripts below retrieve the required secrets from your LastPass account. [`lpass`](https://github.com/lastpass/lastpass-cli) is required.

- [auth-equinix.sh](scripts/auth-equinix.sh)
- [auth-github.sh](scripts/auth-github.sh)
- [auth-redhat.sh](scripts/auth-redhat.sh)

## LCOW Runner

### Create

```shell
source scripts/auth-equinix.sh
source scripts/auth-github.sh
(cd lcow && terraform init && terraform apply)
```

- **Expected execution time:** ~35 minutes

### Info

To view credentials for a runner, execute:

```shell
source scripts/auth-equinix.sh
source scripts/auth-github.sh
(cd lcow && terraform init && terraform output)
```

The password for the machine is marked 'sensitive'. To view the password, you must explicitly request to view its contents:

```bash
source scripts/auth-equinix.sh
source scripts/auth-github.sh
(cd lcow && terraform init && terraform output root_password)
```

### Destroy

```shell
source scripts/auth-equinix.sh
source scripts/auth-github.sh
(cd lcow && terraform init && terraform destroy)
```

## RHEL Runner

### Create

```shell
source scripts/auth-equinix.sh
source scripts/auth-github.sh
source scripts/auth-redhat.sh
(cd rhel-openshift && terraform init && terraform apply)
```

- **Expected execution time:** 20 minutes

### Info

```shell
(cd rhel-openshift && terraform output)
```

### Destroy

```shell
source scripts/auth-equinix.sh
source scripts/auth-github.sh
source scripts/auth-redhat.sh
(cd rhel-openshift && terraform init && terraform destroy)
```
