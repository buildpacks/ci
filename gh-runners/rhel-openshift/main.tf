provider "metal" {
  auth_token = var.METAL_AUTH_TOKEN
}

###
# MACHINE
###
resource "metal_device" "machine" {
  project_id       = var.METAL_PROJECT_ID
  hostname         = "rhel-openshift-gh-runner"
  operating_system = "rhel_8"
  facilities       = ["ny5"]
  plan             = "c3.small.x86"
  billing_cycle    = "hourly"
  user_data        = file("provision-scripts/user-data.tpl.sh")

  connection {
    type    = "ssh"
    user    = "root"
    host    = self.access_public_ipv4
    timeout = "5m"
  }

  ##
  # Create
  ##
  provisioner "file" {
    content = replace(replace(
      file("provision-scripts/redhat.create.tpl.sh"),
      "%RH_USERNAME%", var.RH_USERNAME),
      "%RH_PASSWORD%", var.RH_PASSWORD
    )
    destination = "/tmp/provision-redhat.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-redhat.create.sh",
      "/tmp/provision-redhat.create.sh",
    ]
  }

  ##
  # Destroy
  ##
  provisioner "remote-exec" {
    when   = destroy
    script = "provision-scripts/redhat.destroy.tpl.sh"
  }
}

output "ipv4" {
  value = metal_device.machine.access_public_ipv4
}

###
# GITHUB RUNNER
###
locals {
  repos = toset(["tekton-integration"])
}

resource "null_resource" "github_runner" {
  for_each = local.repos

  connection {
    host = metal_device.machine.access_public_ipv4
  }

  provisioner "file" {
    content = replace(replace(replace(replace(
      file("provision-scripts/github-runner.create.tpl.sh"),
      "%GH_TOKEN%", var.GH_TOKEN),
      "%GH_OWNER%", "buildpacks"),
      "%GH_REPO%", each.key),
      "%GH_RUNNER_VERSION%", var.GH_RUNNER_VERSION
    )
    destination = "/tmp/provision-github-runner.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-github-runner.create.sh",
      "sudo -i -u user bash /tmp/provision-github-runner.create.sh",
    ]
  }

  depends_on = [null_resource.github_runner_destroy]
}

resource "null_resource" "github_runner_destroy" {
  for_each = local.repos

  triggers = {
    ipv4 = metal_device.machine.access_public_ipv4
  }

  connection {
    host = self.triggers.ipv4
  }

  provisioner "file" {
    when = destroy
    content = replace(replace(
      file("provision-scripts/github-runner.destroy.tpl.sh"),
      "%GH_OWNER%", "buildpacks"),
      "%GH_REPO%", each.key
    )
    destination = "/tmp/provision-github-runner.destroy.sh"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/provision-github-runner.destroy.sh",
      "sudo -i -u user bash /tmp/provision-github-runner.destroy.sh",
    ]
  }
}

###
# CODEREADY CONTAINERS
###
resource "null_resource" "codeready_containers" {
  connection {
    host = metal_device.machine.access_public_ipv4
  }

  provisioner "file" {
    content = replace(
      file("provision-scripts/codeready-containers.create.tpl.sh"),
      "%RH_PULL_SECRET%", var.RH_PULL_SECRET
    )
    destination = "/tmp/provision-codeready-containers.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-codeready-containers.create.sh",
      "sudo -i -u user bash /tmp/provision-codeready-containers.create.sh",
    ]
  }
}
