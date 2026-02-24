################### VPC ################### 

#creation of VPC
resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_boca_network_name
  auto_create_subnetworks = false
}

################### SUBNETS ################### 

#creation of 1st subnet
resource "google_compute_subnetwork" "subnet1" {
  name          = var.boca_primary_subnet_name
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = var.boca_primary_subnet_cidr
  region        = var.primary_region
}

#creation of 2nd subnet
resource "google_compute_subnetwork" "subnet2" {
  name          = var.boca_secondary_subnet_name
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = var.boca_secondary_subnet_cidr
  region        = var.secondary_region
}

################### FIREWALL ################### 

#creation of firewall rules
resource "google_compute_firewall" "allow_https" {
  target_tags = ["https-server"]
  name        = "allow-https"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_https_port]
  }

  source_ranges = var.safety_ingress_cidr
}

resource "google_compute_firewall" "allow_http" {
  target_tags = ["http-server"]
  name        = "allow-http"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_http_port]
  }

  source_ranges = var.safety_ingress_cidr
}

resource "google_compute_firewall" "allow_ssh" {
  target_tags = ["ssh"]
  name        = "allow-ssh"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_ssh_port]
  }

  source_ranges = var.safety_ingress_cidr
}

resource "google_compute_firewall" "allow_icmp" {
  target_tags = ["ping"]
  name        = "allow-ping"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "icmp"
  }

  source_ranges = var.safety_ingress_cidr
}

resource "google_compute_firewall" "allow_intra_animeitor" {
  target_tags = ["boca"]
  name        = "allow-intra-animeitor"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_http_port, var.firewall_https_port]
  }

  source_ranges = [var.animeitor_subnet_cidr]
}

resource "google_compute_firewall" "allow_postgresql" {
  target_tags = ["replication"]
  name        = "allow-postgresql"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_postgresql_port]
  }

  source_ranges = [var.boca_primary_subnet_cidr, var.boca_secondary_subnet_cidr, var.animeitor_subnet_cidr]
  # source_ranges = ["35.211.103.119/32", "35.209.28.159/32"]
}

################### STATIC IPs ################### 

#reservation of primary BOCA static IP
resource "google_compute_address" "static_ip_vm1" {
  name         = "static-ip-boca-01"
  network_tier = "STANDARD"
  region       = var.primary_region
}

#reservation of secondary BOCA static IP
resource "google_compute_address" "static_ip_vm2" {
  name         = "static-ip-boca-02"
  network_tier = "STANDARD"
  region       = var.secondary_region
}

################### VMs ################### 

#creation of primary BOCA VM
resource "google_compute_instance" "vm4" {
  name         = var.name_boca_primary
  machine_type = var.default_shape_machine_primary
  zone         = var.primary_zone
  tags         = ["http-server", "https-server", "ssh", "boca", "replication"]

  boot_disk {
    initialize_params {
      image = var.image_os_boca
      size  = var.new_disk_size_boca
      type  = var.disk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet1.id
    access_config {
      nat_ip       = google_compute_address.static_ip_vm1.address
      network_tier = "STANDARD"
    }
  }
}

#creation of secondary BOCA VM
resource "google_compute_instance" "vm5" {
  name         = var.name_boca_secondary
  machine_type = var.default_shape_machine_secondary
  zone         = var.secondary_zone
  tags         = ["http-server", "https-server", "ssh", "boca", "replication"]

  boot_disk {
    initialize_params {
      image = var.image_os_boca
      size  = var.new_disk_size_boca
      type  = var.disk_type
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet2.id
    access_config {
      nat_ip       = google_compute_address.static_ip_vm2.address
      network_tier = "STANDARD"
    }
  }
}