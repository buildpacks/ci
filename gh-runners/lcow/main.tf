provider "metal" {
  auth_token = var.METAL_AUTH_TOKEN
}

resource "metal_device" "machine" {
  project_id       = var.METAL_PROJECT_ID
  hostname         = "windows-lcow-gh-runner"
  operating_system = "windows_2019"
  facilities       = ["dfw2"]
  plan             = "c3.small.x86"
  billing_cycle    = "hourly"
  user_data        = file("provision-scripts/user_data.ps1")

  connection {
    host        = self.access_public_ipv4
    user        = "Admin"
    password    = self.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
  }

  provisioner "local-exec" {
    command = "./provision-scripts/wait-for-ssh.sh ${self.access_public_ipv4}"
  }
}

###
# DEPENDENCIES
###
resource "null_resource" "dependencies" {
  triggers = {
    sha = sha1(file("provision-scripts/dependencies.ps1"))
  }

  connection {
    host        = metal_device.machine.access_public_ipv4
    user        = "Admin"
    password    = metal_device.machine.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
  }

  provisioner "file" {
    source      = "provision-scripts/dependencies.ps1"
    destination = "C:/dependencies.ps1"
  }

  provisioner "remote-exec" {
    inline = ["powershell.exe C:/dependencies.ps1"]
  }
}

###
# GITHUB RUNNER
###
locals {
  repos = toset(["pack"])
}

resource "null_resource" "github_runner_create" {
  for_each = local.repos

  triggers = {
    sha = sha1(file("provision-scripts/github-runner.create.ps1"))
  }

  connection {
    host        = metal_device.machine.access_public_ipv4
    user        = "Admin"
    password    = metal_device.machine.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
  }

  provisioner "file" {
    source      = "provision-scripts/github-runner.create.ps1"
    destination = "C:/github-runner.create.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C:/github-runner.create.ps1 -Owner buildpacks -Repo ${each.key} -Token ${var.GH_TOKEN} -Version ${var.GH_RUNNER_VERSION} -ServiceAccount Admin -ServicePassword \"${metal_device.machine.root_password}\""
    ]
  }

  depends_on = [null_resource.dependencies, null_resource.github_runner_destroy]
}

resource "null_resource" "github_runner_destroy" {
  for_each = local.repos

  triggers = {
    public_ip = metal_device.machine.access_public_ipv4
  }

  connection {
    host = self.triggers.public_ip
  }

  provisioner "file" {
    when        = destroy
    source      = "provision-scripts/github-runner.destroy.ps1"
    destination = "C:/github-runner.destroy.ps1"
  }


  provisioner "remote-exec" {
    when = destroy
    inline = [
      "powershell.exe -File C:/github-runner.destroy.ps1 -Owner buildpacks -Repo ${each.key}"
    ]
  }
}


output "hostname" {
  value = metal_device.machine.hostname
}

output "root_username" {
  value = "Admin"
}

output "root_password" {
  value     = metal_device.machine.root_password
  sensitive = true
}

output "public_ip" {
  value = metal_device.machine.access_public_ipv4
}
