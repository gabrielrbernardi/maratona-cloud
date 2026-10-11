################## IMPORTED VMs ###################

import {
  to = google_compute_instance.proxy_test
  id = "projects/${var.project}/zones/us-central1-a/instances/proxy-test"
}

resource "google_compute_instance" "proxy_test" {
  name         = "proxy-test"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  tags         = ["http-server", "https-server", "ssh"]

  boot_disk {
    auto_delete = true
    device_name = "proxy-test"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20260225"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_proxy_network.id
    subnetwork = google_compute_subnetwork.subnet_proxy.id

    access_config {
      nat_ip       = google_compute_address.static_ip_reverse_proxy.address
      network_tier = "STANDARD"
    }
  }

  metadata = {
    enable-osconfig = "TRUE"
  }

  service_account {
    email = "396540519058-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  lifecycle {
    # ssh-keys are injected by gcloud/console SSH and change frequently.
    ignore_changes = [metadata["ssh-keys"]]
  }
}
