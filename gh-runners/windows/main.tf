provider "metal" {
  auth_token = var.METAL_AUTH_TOKEN
}

resource "metal_device" "windows-lcow" {
  project_id       = var.METAL_PROJECT_ID
  hostname         = "windows-lcow-gh-runner"
  operating_system = "windows_2019"
  facilities       = ["dfw2", "iad2"]
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

resource "metal_device" "windows-workstation1" {
  project_id       = var.METAL_PROJECT_ID
  hostname         = "windows-workstation1"
  operating_system = "windows_2019"
  facilities       = ["dfw2", "iad2"]
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

locals {
  machines = {
    "lcow" : metal_device.windows-lcow,
    "workstation1" : metal_device.windows-workstation1
  }
}

###
# DEPENDENCIES
###
resource "null_resource" "dependencies" {
  for_each = local.machines

  triggers = {
    sha           = sha1(file("provision-scripts/dependencies.ps1"))
    public_ip     = each.value.access_public_ipv4
    root_password = each.value.root_password
  }

  connection {
    host        = self.triggers.public_ip
    user        = "Admin"
    password    = self.triggers.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
  }

  provisioner "file" {
    source      = "provision-scripts/dependencies.ps1"
    destination = "C:/dependencies.ps1"
  }

  provisioner "remote-exec" {
    inline = ["powershell.exe C:/dependencies.ps1"]
  }

  provisioner "local-exec" {
    command = "sleep 5 && ./provision-scripts/wait-for-ssh.sh ${self.triggers.public_ip}"
  }
}

###
# DOCKER
###
resource "null_resource" "docker" {
  for_each = local.machines

  triggers = {
    sha           = sha1(file("provision-scripts/docker.create.ps1"))
    public_ip     = each.value.access_public_ipv4
    root_password = each.value.root_password
  }

  depends_on = [null_resource.dependencies]

  connection {
    host        = self.triggers.public_ip
    user        = "Admin"
    password    = self.triggers.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
  }

  provisioner "file" {
    source      = "provision-scripts/docker.create.ps1"
    destination = "C:/docker.create.ps1"
  }

  provisioner "remote-exec" {
    inline = ["powershell.exe C:/docker.create.ps1"]
  }

  provisioner "local-exec" {
    command = "sleep 5 && ./provision-scripts/wait-for-ssh.sh ${self.triggers.public_ip}"
  }

  # ------ DESTROY ------

  provisioner "file" {
    when        = destroy
    source      = "provision-scripts/docker.destroy.ps1"
    destination = "C:/docker.destroy.ps1"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "powershell.exe -File C:/docker.destroy.ps1"
    ]
  }
}

###
# GITHUB RUNNER
###
locals {
  repos = toset(["pack"])
}

resource "null_resource" "github_runner" {
  for_each = local.repos

  triggers = {
    sha           = sha1(file("provision-scripts/github-runner.create.ps1"))
    public_ip     = metal_device.windows-lcow.access_public_ipv4
    root_password = metal_device.windows-lcow.root_password
    github_token  = var.GH_TOKEN
  }

  connection {
    host        = self.triggers.public_ip
    user        = "Admin"
    password    = self.triggers.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
  }

  provisioner "file" {
    source      = "provision-scripts/github-runner.create.ps1"
    destination = "C:/github-runner.create.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C:/github-runner.create.ps1 -Owner buildpacks -Repo ${each.key} -Token ${self.triggers.github_token} -Version ${var.GH_RUNNER_VERSION} -ServiceAccount Admin -ServicePassword \"${self.triggers.root_password}\""
    ]
  }

  # ------ DESTROY ------

  provisioner "file" {
    when        = destroy
    source      = "provision-scripts/github-runner.destroy.ps1"
    destination = "C:/github-runner.destroy.ps1"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "powershell.exe -File C:/github-runner.destroy.ps1 -Owner buildpacks -Repo ${each.key} -Token ${self.triggers.github_token}"
    ]
  }

  depends_on = [null_resource.dependencies]
}


output "machine_info" {
  value = {
    for machine in local.machines :
    machine.hostname => {
      "public_ip" : machine.access_public_ipv4
      "root_username" : "Admin"
      "root_password" : machine.access_public_ipv4
    }
  }
}
