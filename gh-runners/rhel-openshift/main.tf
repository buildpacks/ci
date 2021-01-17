provider "metal" {
  auth_token = var.METAL_AUTH_TOKEN
}

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

  ###
  # FILL AND UPLOAD PROVISION SCRIPTS
  ##
  provisioner "remote-exec" {
    inline = ["mkdir -p /tmp/provision/"]
  }

  provisioner "file" {
    content = replace(
      file("provision-scripts/codeready-containers.tpl.sh"),
      "%RH_PULL_SECRET%", var.RH_PULL_SECRET
    )
    destination = "/tmp/provision/codeready-containers.sh"
  }

  provisioner "file" {
    content = replace(replace(replace(replace(
      file("provision-scripts/github-runner.tpl.sh"),
      "%GH_TOKEN%", var.GH_TOKEN),
      "%GH_ORG%", var.GH_ORG),
      "%GH_REPO%", var.GH_REPO),
      "%GH_RUNNER_VERSION%", var.GH_RUNNER_VERSION
    )
    destination = "/tmp/provision/github-runner.sh"
  }

  provisioner "file" {
    content = replace(replace(
      file("provision-scripts/redhat.tpl.sh"),
      "%RH_USERNAME%", var.RH_USERNAME),
      "%RH_PASSWORD%", var.RH_PASSWORD
    )
    destination = "/tmp/provision/redhat.sh"
  }

  ###
  # EXECUTE PROVISION SCRIPTS
  ##
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision/*.sh",
      "/tmp/provision/redhat.sh",
      "sudo -i -u user bash /tmp/provision/github-runner.sh",
      "sudo -i -u user bash /tmp/provision/codeready-containers.sh",
    ]
  }

  ###
  # Destroy
  ##
  provisioner "remote-exec" {
    when   = destroy
    inline = ["subscription-manager register"]
  }
}
