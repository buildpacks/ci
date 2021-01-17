variable "PACKET_AUTH_TOKEN" {
  type        = string
  description = "Auth Token for connection to packet.net"
}

variable "PACKET_PROJECT_ID" {
  type        = string
  description = "Packet Project GUID"
}

provider "packet" {
  auth_token = var.PACKET_AUTH_TOKEN
}

locals {
  project_id = var.PACKET_PROJECT_ID
}

resource "packet_device" "gha_lcow" {
  hostname            = "windows-lcow"
  plan                = "c3.small.x86"
  facilities          = ["dfw2"]
  operating_system    = "windows_2019"
  billing_cycle       = "hourly"
  project_id          = local.project_id
  user_data           = file("user_data.ps1")
}

resource "null_resource" "provision" {
  connection {
    type = "ssh"
    host = packet_device.gha_lcow.access_public_ipv4
    user = "Admin"
    password = packet_device.gha_lcow.root_password
    script_path = "/Windows/Temp/terraform_%RAND%.bat"
  }

  provisioner "local-exec" {
    command = "./wait-for-ssh.sh ${packet_device.gha_lcow.access_public_ipv4}"
  }

  provisioner "file" {
    source = "provision.ps1"
    destination = "C:/provision.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe C:/provision.ps1 > C:/provision.log"
    ]
  }
}

output "hostname" {
  value = packet_device.gha_lcow.hostname
}

output "root_username" {
  value = "Admin"
}

output "root_password" {
  value = packet_device.gha_lcow.root_password
  sensitive = true
}

output "public_ip" {
  value = packet_device.gha_lcow.access_public_ipv4
}