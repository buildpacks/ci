provider "equinix" {
  auth_token = var.METAL_AUTH_TOKEN
}

resource "equinix_metal_device" "linux-arm64" {
  project_id       = var.METAL_PROJECT_ID
  hostname         = "linux-arm64-gh-runner"
  plan             = "c3.large.arm64"
  facilities       = ["da11"]
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"

  connection {
    host     = self.access_public_ipv4
    password = self.root_password
  }

  ##
  # Create
  ##

  ## Dependencies

  provisioner "file" {
    source      = "provision-scripts/dependencies.sh"
    destination = "/tmp/provision-dependencies.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision-dependencies.sh",
      "/tmp/provision-dependencies.sh",
    ]
  }

  ## GitHub Runner

  provisioner "file" {
    source      = "provision-scripts/github-runner.create.sh"
    destination = "/tmp/github-runner.create.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/github-runner.create.sh",
      "GH_OWNER=${var.GH_OWNER} GH_REPO=${var.GH_REPO} GH_RUNNER_SHA256=${var.GH_RUNNER_SHA256} GH_RUNNER_VERSION=${var.GH_RUNNER_VERSION} GH_RUNNER_REG_TOKEN=${var.GH_RUNNER_REG_TOKEN} /tmp/github-runner.create.sh",
    ]
  }
}
