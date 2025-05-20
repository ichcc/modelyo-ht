provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "controller" {
  metadata = {
  ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_path)}"
}
  name         = var.controller_name
  machine_type = var.machine_type
  zone         = var.zone
  allow_stopping_for_update = true
  tags = ["ssh"] 

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
  network = google_compute_network.openstack_net.self_link
  subnetwork = google_compute_subnetwork.openstack_subnet.self_link
    
    access_config {
      nat_ip = google_compute_address.controller_ip.address # or compute_ip for compute
    }
  }
}

resource "google_compute_instance" "compute" {
  metadata = {
  ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_path)}"
}
  name         = var.compute_name
  machine_type = var.machine_type
  zone         = var.zone
  allow_stopping_for_update = true 
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
  network = google_compute_network.openstack_net.self_link
  subnetwork = google_compute_subnetwork.openstack_subnet.self_link
    
  access_config {
    nat_ip = google_compute_address.compute_ip.address # or compute_ip for compute
  }
  }
  tags = ["ssh"]
}

resource "google_compute_network" "openstack_net" {
  name                    = "openstack-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "openstack_subnet" {
  name          = "openstack-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.openstack_net.id
}

resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.openstack_net.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}


resource "google_compute_address" "controller_ip" {
  name   = "controller-ip"
  region = var.region
}

resource "google_compute_address" "compute_ip" {
  name   = "compute-ip"
  region = var.region
}


output "controller_ip" {
  value = google_compute_address.controller_ip.address
}

output "compute_ip" {
  value = google_compute_address.compute_ip.address
}