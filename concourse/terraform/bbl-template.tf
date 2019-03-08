variable "project_id" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "zone" {
  type = "string"
}

variable "env_id" {
  type = "string"
}

variable "credentials" {
  type = "string"
}

provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.project_id}"
  region      = "${var.region}"

  version = "~> 1.20"
}

variable "subnet_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

resource "google_compute_network" "bbl-network" {
  name                    = "${var.env_id}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "bbl-subnet" {
  name          = "${var.env_id}-subnet"
  ip_cidr_range = "${var.subnet_cidr}"
  network       = "${google_compute_network.bbl-network.self_link}"
}

resource "google_compute_firewall" "external" {
  name    = "${var.env_id}-external"
  network = "${google_compute_network.bbl-network.name}"

  source_ranges = ["0.0.0.0/0"]

  allow {
    ports    = ["22", "6868", "25555"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-bosh-open"]
}

resource "google_compute_firewall" "bosh-open" {
  name    = "${var.env_id}-bosh-open"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-bosh-open"]

  allow {
    ports    = ["22", "6868", "8443", "8844", "25555"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-bosh-director"]
}

resource "google_compute_firewall" "bosh-director" {
  name    = "${var.env_id}-bosh-director"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-bosh-director"]

  allow {
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-internal"]
}

resource "google_compute_firewall" "internal-to-director" {
  name    = "${var.env_id}-internal-to-director"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-internal"]

  allow {
    ports    = ["4222", "25250", "25777"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-bosh-director"]
}

resource "google_compute_firewall" "jumpbox-to-all" {
  name    = "${var.env_id}-jumpbox-to-all"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-jumpbox"]

  allow {
    ports    = ["22", "3389"]
    protocol = "tcp"
  }

  target_tags = ["${var.env_id}-internal", "${var.env_id}-bosh-director"]
}

resource "google_compute_firewall" "internal" {
  name    = "${var.env_id}-internal"
  network = "${google_compute_network.bbl-network.name}"

  source_tags = ["${var.env_id}-internal"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  target_tags = ["${var.env_id}-internal"]
}

output "network" {
  value = "${google_compute_network.bbl-network.name}"
}

output "subnetwork" {
  value = "${google_compute_subnetwork.bbl-subnet.name}"
}

output "internal_cidr" {
  value = "${var.subnet_cidr}"
}

output "internal_gw" {
  value = "${google_compute_subnetwork.bbl-subnet.gateway_address}"
}

output "director_name" {
  value = "bosh-${var.env_id}"
}

output "jumpbox__internal_ip" {
  value = "${cidrhost(var.subnet_cidr, 5)}"
}

output "director__internal_ip" {
  value = "${cidrhost(var.subnet_cidr, 6)}"
}

output "jumpbox__tags" {
  value = [
    "${google_compute_firewall.bosh-open.name}",
    "${var.env_id}-jumpbox",
  ]
}

output "director__tags" {
  value = ["${google_compute_firewall.bosh-director.name}"]
}

output "internal_tag_name" {
  value = "${google_compute_firewall.internal.name}"
}

resource "google_compute_address" "jumpbox-ip" {
  name = "${var.env_id}-jumpbox-ip"
}

output "jumpbox_url" {
  value = "${google_compute_address.jumpbox-ip.address}:22"
}

output "external_ip" {
  value = "${google_compute_address.jumpbox-ip.address}"
}

output "director_address" {
  value = "https://${google_compute_address.jumpbox-ip.address}:25555"
}

output "concourse_target_pool" {
  value = "${google_compute_target_pool.target-pool.name}"
}

output "concourse_lb_ip" {
  value = "${google_compute_address.concourse-address.address}"
}

resource "google_compute_firewall" "firewall-concourse" {
  name    = "${var.env_id}-concourse-open"
  network = "${google_compute_network.bbl-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2222", "8443", "8844"]
  }

  target_tags = ["concourse"]
}

resource "google_compute_address" "concourse-address" {
  name = "${var.env_id}-concourse"
}

resource "google_compute_target_pool" "target-pool" {
  name = "${var.env_id}-concourse"

  session_affinity = "NONE"
}

resource "google_compute_forwarding_rule" "ssh-forwarding-rule" {
  name        = "${var.env_id}-concourse-ssh"
  target      = "${google_compute_target_pool.target-pool.self_link}"
  port_range  = "2222"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.concourse-address.address}"
}

resource "google_compute_forwarding_rule" "https-forwarding-rule" {
  name        = "${var.env_id}-concourse-https"
  target      = "${google_compute_target_pool.target-pool.self_link}"
  port_range  = "443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.concourse-address.address}"
}

resource "google_compute_forwarding_rule" "http-forwarding-rule" {
  name        = "${var.env_id}-concourse-http"
  target      = "${google_compute_target_pool.target-pool.self_link}"
  port_range  = "80"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.concourse-address.address}"
}

resource "google_compute_forwarding_rule" "credhub-forwarding-rule" {
  name        = "${var.env_id}-concourse-credhub"
  target      = "${google_compute_target_pool.target-pool.self_link}"
  port_range  = "8844"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.concourse-address.address}"
}

resource "google_compute_forwarding_rule" "uaa-forwarding-rule" {
  name        = "${var.env_id}-concourse-uaa"
  target      = "${google_compute_target_pool.target-pool.self_link}"
  port_range  = "8443"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.concourse-address.address}"
}
