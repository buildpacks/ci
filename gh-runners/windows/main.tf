provider "metal" {
  auth_token = var.METAL_AUTH_TOKEN
}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "!"
}

resource "metal_device" "windows-lcow" {
  project_id       = var.METAL_PROJECT_ID
  hostname         = "windows-lcow"
  operating_system = "windows_2019"
  facilities       = ["da11", "dfw2", "dc13"]
  plan             = "c3.small.x86"
  billing_cycle    = "hourly"
  user_data = templatefile(
    "provision-scripts/user_data.ps1",
    {
      admin_username = "Admin"
      admin_password = random_string.password.result
    }
  )
}

resource "metal_device" "windows-dev1" {
  project_id       = var.METAL_PROJECT_ID
  hostname         = "windows-dev1"
  operating_system = "windows_2019"
  facilities       = ["da11", "dfw2", "dc13"]
  plan             = "c3.small.x86"
  billing_cycle    = "hourly"
  user_data = templatefile(
    "provision-scripts/user_data.ps1",
    {
      admin_username = "Admin"
      admin_password = random_string.password.result
    }
  )
}

locals {
  machines = {
    "lcow" : metal_device.windows-lcow,
    "dev1" : metal_device.windows-dev1
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
    root_password = random_string.password.result
  }

  connection {
    host        = self.triggers.public_ip
    user        = "Admin"
    password    = self.triggers.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
    timeout     = "15m"
  }

  provisioner "file" {
    source      = "provision-scripts/dependencies.ps1"
    destination = "C:/dependencies.ps1"
  }

  provisioner "remote-exec" {
    inline = ["powershell.exe C:/dependencies.ps1"]
  }

  provisioner "local-exec" {
    command = "sleep 20"
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
    root_password = random_string.password.result
  }

  depends_on = [null_resource.dependencies]

  connection {
    host        = self.triggers.public_ip
    user        = "Admin"
    password    = self.triggers.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
    timeout     = "15m"
  }

  provisioner "file" {
    source      = "provision-scripts/docker.create.ps1"
    destination = "C:/docker.create.ps1"
  }

  provisioner "remote-exec" {
    inline = ["powershell.exe C:/docker.create.ps1"]
  }

  provisioner "local-exec" {
    command = "sleep 20"
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

  // creates a flattend list such as
  // - (machine=1, label=X, repo=1)
  // - (machine=1, label=X, repo=2)
  // - (machine=2, label=Y, repo=1)
  // - (machine=2, label=Y, repo=2)
  runner_machines = flatten([
    for label, machine in {
      "lcow" : metal_device.windows-lcow
      } : [
      for repo in local.repos : {
        machine : machine,
        label : label,
        repo : repo
      }
    ]
  ])
}

resource "null_resource" "github_runner" {
  for_each = {
    for data in local.runner_machines : "${data.machine.hostname}.${data.repo}" => data
  }

  triggers = {
    sha           = sha1(file("provision-scripts/github-runner.create.ps1"))
    public_ip     = each.value.machine.access_public_ipv4
    root_password = random_string.password.result
    github_token  = var.GH_TOKEN
    repo          = each.value.repo
    label         = each.value.label
  }

  connection {
    host        = self.triggers.public_ip
    user        = "Admin"
    password    = self.triggers.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
    timeout     = "15m"
  }

  provisioner "file" {
    source      = "provision-scripts/github-runner.create.ps1"
    destination = "C:/github-runner.create.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File C:/github-runner.create.ps1 -Owner buildpacks -Repo ${self.triggers.repo} -Label ${self.triggers.label}  -Token ${self.triggers.github_token} -Version ${var.GH_RUNNER_VERSION} -ServiceAccount Admin -ServicePassword \"${self.triggers.root_password}\""
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
      "root_password" : random_string.password.result
    }
  }
}
