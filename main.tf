provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "controller" {
  name         = var.controller_name
  machine_type = var.machine_type
  zone         = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_instance" "compute" {
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
    network = "default"
    subnetwork = google_compute_subnetwork.openstack_subnet.name
    access_config {}
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

