# Usage

For managing a Windows Github Actions Runner, one only needs to interact with the _terraform wrapper_ script at: `./scripts/terraformw.sh`. The script wraps terraform commands; performing any prep steps before the main operations.

## Configure LastPass First

The script assumes that the following 2 credential notes are available in LastPass:

1.  **PACKET_AUTH_TOKEN:** An authentication token that allows terraform to manage instances on your behalf.
    ```
    lpass show --note 'Shared-Cloud Native Buildpacks/packet-auth-token'
    ```
1.  **PACKET_PROJECT_ID:** The GUID representing a packet project where instances will be created.
    ```
    lpass show --note 'Shared-Cloud Native Buildpacks/packet-project-id'
    ```

## Create a runner

To create a runner, invoke the _terraform wrapper_ script without any arguments:
```bash
# pwd: ~/workspace/ci/runners
$ ./scripts/terraformw.sh
...
```

> **Note:** This command will take about 20 minutes.

The process will standup a windows machine and perform _the bulk_ of the provisioning steps. These steps include: Installing Hyper-V/Docker-Desktop, Preparing the `actions-runner-win-x64-*.zip` archive, Rebooting the Machine, and more.

However after the creation process is completed, one must still manually **log into the machine and turn on the Docker-Desktop Application**. (It has proven difficult to do well programmatically).

## Destroying a runner

To destroy a runner, invoke the _terraform wrapper_ script with the `destroy` argument:
```bash
# pwd: ~/workspace/ci/runners
$ ./scripts/terraformw.sh destroy
...
```

> **Note:** This command will take about 6 seconds.

## Viewing runner credentials

To view credentials for a runner, invoke the _terraform wrapper_ script with the `output` argument:
```bash
# pwd: ~/workspace/ci/runners
$ ./scripts/terraformw.sh output
...
hostname = windows-lcow
public_ip = xxx.xx.xx.100
root_password = <sensitive>
root_username = Admin
```

The password for the machine is marked 'sensitive'. To view the password, you must explicitly request to view its contents:
```bash
# pwd: ~/workspace/ci/runners
$ ./scripts/terraformw.sh output root_password
...
0123abcdefghijklmn
```

## Other

* To specify the type of machine to be created, one must [edit the `packet_device.gha_lcow` resource definition of `main.tf`](./terraform/main.tf). The documentation can be found [here](https://registry.terraform.io/providers/packethost/packet/latest/docs/resources/device#project_ssh_key_ids).
* To adjust what happens during the provisioning process, one must [edit the `provision.ps1`](./terraform/provision.ps1) file.
* Any valid terraform arguments can be passed to `terraformw.sh`.