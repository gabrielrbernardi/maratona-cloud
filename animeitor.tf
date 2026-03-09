

################### VPC ################### 

#creation of VPC
resource "google_compute_network" "vpc_network_animeitor" {
  name                    = var.vpc_animeitor_network_name
  auto_create_subnetworks = false
}

################### SUBNETS ################### 

#creation of 1st subnet
resource "google_compute_subnetwork" "subnet3_animeitor" {
  name          = var.animeitor_subnet_name
  network       = google_compute_network.vpc_network_animeitor.id
  ip_cidr_range = var.animeitor_subnet_cidr
  region        = var.primary_region
}

################### FIREWALL ################### 

#creation of firewall rules
resource "google_compute_firewall" "allow_https_animeitor" {
  target_tags = ["https-server"]
  name        = "allow-https-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_https_port]
  }

  source_ranges = var.safety_ingress_cidr
}

resource "google_compute_firewall" "allow_http_animeitor" {
  target_tags = ["http-server"]
  name        = "allow-http-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_http_port]
  }

  source_ranges = var.safety_ingress_cidr
}

resource "google_compute_firewall" "allow_ssh_animeitor" {
  target_tags = ["ssh"]
  name        = "allow-ssh-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_ssh_port]
  }

  source_ranges = var.general_ingress_cidr
}

resource "google_compute_firewall" "allow_icmp_animeitor" {
  target_tags = ["ping"]
  name        = "allow-ping-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "icmp"
  }

  source_ranges = var.safety_ingress_cidr
}

resource "google_compute_firewall" "allow_proxy_to_animeitor" {
  target_tags = ["proxy-animeitor"]
  name        = "allow-proxy-to-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_http_port, var.firewall_https_port, var.firewall_ssh_port]
  }

  source_ranges = [var.proxy_subnet_cidr]
}

################### STATIC IPs ################### 

#reservation of animeitor's static IP
resource "google_compute_address" "static_ip_vm3_animeitor" {
  name         = "static-ip-animeitor-01"
  network_tier = "STANDARD"
  region       = var.primary_region
}

################### VMs ################### 

#creation of Animeitor VM
resource "google_compute_instance" "vm3_animeitor" {
  name         = var.name_animeitor_vm
  machine_type = var.default_shape_machine_animeitor
  zone         = var.primary_zone
  tags         = ["http-server", "https-server", "ssh", "ping"]

  boot_disk {
    initialize_params {
      image = var.image_os_animeitor
      size  = var.disk_size_animeitor
      type  = var.disk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network_animeitor.id
    subnetwork = google_compute_subnetwork.subnet3_animeitor.id
    access_config {
      nat_ip       = google_compute_address.static_ip_vm3_animeitor.address
      network_tier = "STANDARD"
    }
  }

  metadata = {
    enable-osconfig = "TRUE"
  }
}