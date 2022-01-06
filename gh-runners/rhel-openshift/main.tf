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
  user_data        = file("provision-scripts/user-data.sh")

  connection {
    host     = self.access_public_ipv4
    password = self.root_password
  }

  ##
  # RED HAT
  ##
  provisioner "file" {
    source      = "provision-scripts/redhat.create.sh"
    destination = "/tmp/provision-redhat.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-redhat.create.sh",
      "/tmp/provision-redhat.create.sh -u ${var.RH_USERNAME} -p ${var.RH_PASSWORD}",
    ]
  }

  provisioner "remote-exec" {
    when   = destroy
    script = "provision-scripts/redhat.destroy.sh"
  }

  ###
  # USERS
  ###
  provisioner "file" {
    source      = "provision-scripts/users.create.sh"
    destination = "/tmp/provision-users.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-users.create.sh",
      "/tmp/provision-users.create.sh -u '${var.LOGIN_USERNAME}' -p '${var.LOGIN_PASSWORD}'",
    ]
  }
}


###
# GITHUB RUNNER
###
locals {
  repos = toset(["tekton-integration"])
}

resource "null_resource" "github_runner" {
  for_each = local.repos

  triggers = {
    public_ip      = metal_device.machine.access_public_ipv4
    login_username = var.LOGIN_USERNAME
    login_password = var.LOGIN_PASSWORD
    github_token   = var.GH_TOKEN
  }

  connection {
    host     = self.triggers.public_ip
    user     = self.triggers.login_username
    password = self.triggers.login_password
  }

  provisioner "file" {
    source      = "provision-scripts/github-runner.create.sh"
    destination = "/tmp/provision-github-runner.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-github-runner.create.sh",
      "/tmp/provision-github-runner.create.sh -t ${self.triggers.github_token} -o buildpacks -r ${each.key} -v ${var.GH_RUNNER_VERSION}",
    ]
  }

  # ----- destroy -----

  provisioner "file" {
    when        = destroy
    source      = "provision-scripts/github-runner.destroy.sh"
    destination = "/tmp/provision-github-runner.destroy.sh"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/provision-github-runner.destroy.sh",
      "/tmp/provision-github-runner.destroy.sh  -t ${self.triggers.github_token} -o buildpacks -r ${each.key}",
    ]
  }
}

###
# CODEREADY CONTAINERS
###
resource "null_resource" "codeready_containers" {

  triggers = {
    login_username = var.LOGIN_USERNAME
    login_password = var.LOGIN_PASSWORD
  }

  connection {
    host     = metal_device.machine.access_public_ipv4
    user     = self.triggers.login_username
    password = self.triggers.login_password
  }

  provisioner "file" {
    source      = "provision-scripts/codeready-containers.create.sh"
    destination = "/tmp/provision-codeready-containers.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-codeready-containers.create.sh",
      "/tmp/provision-codeready-containers.create.sh -p '${var.RH_PULL_SECRET}' -v ${var.RH_CRC_VERSION}",
    ]
  }
}

output "public_ip" {
  value = metal_device.machine.access_public_ipv4
}

output "login_user" {
  value = var.LOGIN_USERNAME
}

output "login_password" {
  value     = var.LOGIN_PASSWORD
  sensitive = true
}
