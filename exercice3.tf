provider "google" {
  project = "zonedetest"
  credentials = "account.json"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_instance" "instance1" {
  name         = "instance-terraform-web"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mtl-dmz.name
    access_config {
    }
  }
  metadata_startup_script = "apt-get -y update && apt-get -y upgrade && apt-get -y install apache2 && systemctl start apache2"
}

resource "google_compute_instance" "instance2" {
  name         = "instance-terraform-interne"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1910"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mtl-internal.name
    access_config {
    }
  }
  metadata_startup_script = "apt-get -y update && apt-get -y upgrade"
}

resource "google_compute_network" "cr460demo" {
  name                    = "cr460demo"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "mtl-dmz" {
  name          = "mtl-dmz"
  ip_cidr_range = "172.16.1.0/24"
  region  = "us-central1"
  network       = google_compute_network.cr460demo.self_link
}

resource "google_compute_subnetwork" "mtl-internal" {
  name          = "mtl-internal"
  ip_cidr_range = "10.0.1.0/24"
  region  = "us-central1"
  network       = google_compute_network.cr460demo.self_link
}

resource "google_compute_firewall" "ssh" {
  name    = "ssh"
  network = google_compute_network.cr460demo.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

}

resource "google_compute_firewall" "http" {
  name    = "http"
  network = google_compute_network.cr460demo.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

}
