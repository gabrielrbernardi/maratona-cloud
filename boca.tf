################### VPC ################### 

#creation of VPC
resource "google_compute_network" "vpc_network" {
  name                    = "vpc-boca"
  auto_create_subnetworks = false
}

################### SUBNETS ################### 

#creation of 1st subnet
resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet-us-central1-01"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "192.168.10.0/24"
  region        = var.primary_region
}

#creation of 2nd subnet
resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet-us-east1-01"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "192.168.20.0/24"
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
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {
  target_tags = ["http-server"]
  name        = "allow-http"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  target_tags = ["ssh"]
  name        = "allow-ssh"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp" {
  target_tags = ["ping"]
  name        = "allow-ping"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_intra_animeitor" {
  target_tags = ["boca"]
  name        = "allow-intra-animeitor"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["192.168.30.0/24"]
}

resource "google_compute_firewall" "allow_postgresql" {
  target_tags = ["replication"]
  name        = "allow-postgresql"
  network     = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  # source_ranges = ["35.211.103.119/32", "35.209.28.159/32"]
}

################### STATIC IPs ################### 

#reservation of 1st static IP
resource "google_compute_address" "static_ip_vm1" {
  name         = "static-ip-boca-01"
  network_tier = "STANDARD"
  region       = var.primary_region
}

#reservation of 2nd static IP
resource "google_compute_address" "static_ip_vm2" {
  name         = "static-ip-boca-02"
  network_tier = "STANDARD"
  region       = var.secondary_region
}

# #reservation of 3rd static IP
# resource "google_compute_address" "static_ip_vm5" {
#   name         = "static-ip-boca-05"
#   network_tier = "STANDARD"
#   region       = var.region_01
# }

# #reservation of 4th static IP
# resource "google_compute_address" "static_ip_vm6" {
#   name         = "static-ip-boca-06"
#   network_tier = "STANDARD"
#   region       = var.region_02
# }

# ################### SNAPSHOTS (from existing VMs) ################### 
# # Replace original-vm4-disk and original-vm5-disk with the real disk names

# resource "google_compute_snapshot" "vm4_src_snapshot" {
#   name        = "snapshot-src-vm4"
#   source_disk = "projects/${var.project}/zones/${var.primary_zone}/disks/boca-03"
# }

# resource "google_compute_snapshot" "vm5_src_snapshot" {
#   name        = "snapshot-src-vm5"
#   source_disk = "projects/${var.project}/zones/${var.secondary_zone}/disks/boca-04"
# }

################### VMs ################### 

#creation of 3rd VM
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

#creation of 4th VM
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

############################################

# resource "google_compute_disk" "vm6_disk" {
#   name     = "boot-disk-vm6-clone"
#   type     = var.disk_type
#   zone     = var.zone_01
#   size     = var.new_disk_size_gb
#   snapshot = google_compute_snapshot.vm4_src_snapshot.self_link
# }

# resource "google_compute_disk" "vm7_disk" {
#   name     = "boot-disk-vm7-clone"
#   type     = var.disk_type
#   zone     = var.zone_02
#   size     = var.new_disk_size_gb
#   snapshot = google_compute_snapshot.vm5_src_snapshot.self_link
# }

# resource "google_compute_instance" "vm6" {
#   name         = var.name_vm_06
#   machine_type = var.default_shape_machine_primary
#   zone         = var.zone_01
#   tags         = ["http-server", "https-server", "ssh", "boca", "replication"]

#   boot_disk {
#     source = google_compute_disk.vm6_disk.self_link
#   }

#   network_interface {
#     network    = google_compute_network.vpc_network.id
#     subnetwork = google_compute_subnetwork.subnet1.id
#     access_config {
#       nat_ip       = google_compute_address.static_ip_vm5.address
#       network_tier = "STANDARD"
#     }
#   }
#   depends_on = [google_compute_disk.vm6_disk]
# }

# resource "google_compute_instance" "vm7" {
#   name         = var.name_vm_07
#   machine_type = var.default_shape_machine_secondary
#   zone         = var.zone_02
#   tags         = ["http-server", "https-server", "ssh", "boca", "replication"]

#   boot_disk {
#       source = google_compute_disk.vm7_disk.self_link
#   }

#   network_interface {
#     network    = google_compute_network.vpc_network.id
#     subnetwork = google_compute_subnetwork.subnet2.id
#     access_config {
#       nat_ip       = google_compute_address.static_ip_vm6.address
#       network_tier = "STANDARD"
#     }
#   }
#   depends_on = [google_compute_disk.vm7_disk]
# }