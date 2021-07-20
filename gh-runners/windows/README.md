# Windows LCOW Runner

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

- **Expected execution time:** ~35 minutes

##### Manual steps

###### On LCOW

1. Enable `C:\` drive sharing for volume mounting:
    - `Docker Desktop` -> `Settings` -> `Resources` -> `File Sharing`
    - Enter `C:\` -> Keypress `Enter`
    - Press `Apply & Restart`

###### On WCOW

1. Change to Windows containers:
    1. In the system tray, Right-Click the Docker icon
    2. Click `Switch to Windows containers`
2. Add internal IP address to `hosts` files:
    In an Administrative Powershell,
    ```powershell
    $IPAddress=(Get-NetIPAddress -InterfaceAlias bond0 -AddressFamily IPv4).IPAddress | grep 10
    "# Modified by CNB: https://github.com/buildpacks/ci/tree/main/gh-runners/windows
    ${IPAddress} host.docker.internal
    ${IPAddress} gateway.docker.internal
    " | Out-File -Filepath C:\Windows\System32\drivers\etc\hosts -Encoding utf8
    ```
3. Set internal registries as insecure:
    1. In Docker settings, Click `Docker Engine`
    2. Add `10.0.0.0/8` to the `insecure-registries` list:
        ```json
        {
            "registry-mirrors": [],
            "insecure-registries": ["10.0.0.0/8"],
            "debug": false,
            "experimental": false
        }
        ```
    3. Click `Apply & Restart`

### Info

```shell
terraform output
```

### Destroy

```shell
./../scripts/auth-terraform.sh
terraform init
terraform destroy
```
