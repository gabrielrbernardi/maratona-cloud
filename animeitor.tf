

################### VPC ################### 

#creation of VPC
resource "google_compute_network" "vpc_network_animeitor" {
  name                    = "vpc-animeitor"
  auto_create_subnetworks = false
}

################### SUBNETS ################### 

#creation of 1st subnet
resource "google_compute_subnetwork" "subnet3_animeitor" {
  name          = "subnet-us-central1-02"
  network       = google_compute_network.vpc_network_animeitor.id
  ip_cidr_range = "192.168.30.0/24"
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
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http_animeitor" {
  target_tags = ["http-server"]
  name        = "allow-http-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh_animeitor" {
  target_tags = ["ssh"]
  name        = "allow-ssh-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_icmp_animeitor" {
  target_tags = ["ping"]
  name        = "allow-ping-animeitor"
  network     = google_compute_network.vpc_network_animeitor.id

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

################### STATIC IPs ################### 

#reservation of 1st static IP
resource "google_compute_address" "static_ip_vm3_animeitor" {
  name         = "static-ip-animeitor-01"
  network_tier = "STANDARD"
  region       = var.primary_region
}

# #reservation of 2nd static IP
# resource "google_compute_address" "static_ip_vm7_animeitor" {
#   name         = "static-ip-animeitor-02"
#   network_tier = "STANDARD"
#   region       = var.region_01
# }

# ################### SNAPTHOTS ###################

# resource "google_compute_snapshot" "vm8_src_snapshot" {
#   name        = "snapshot-src-vm8"
#   source_disk = "projects/${var.project}/zones/${var.zone_01}/disks/animeitor-01"
# }

################### VMs ################### 

#creation of 1st VM
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
}

# resource "google_compute_disk" "vm8_disk" {
#   name     = "boot-disk-vm8-clone"
#   type     = var.disk_type
#   zone     = var.zone_01
#   size     = var.disk_size_gb
#   snapshot = google_compute_snapshot.vm8_src_snapshot.self_link
# }

# #creation of 2nd VM
# resource "google_compute_instance" "vm8_animeitor" {
#   name         = var.name_vm_08
#   machine_type = var.default_shape_machine_animeitor
#   zone         = var.zone_01
#   tags         = ["http-server", "https-server", "ssh", "ping"]

#   boot_disk {
#       source = google_compute_disk.vm8_disk.self_link
#   }

#   network_interface {
#     network    = google_compute_network.vpc_network_animeitor.id
#     subnetwork = google_compute_subnetwork.subnet3_animeitor.id
#     access_config {
#       nat_ip       = google_compute_address.static_ip_vm7_animeitor.address
#       network_tier = "STANDARD"
#     }
#   }
  
#   depends_on = [google_compute_disk.vm8_disk]
# }