################## VPC ################### 

#creation of VPC
resource "google_compute_network" "vpc_proxy_network" {
  name                    = var.proxy_vpc_name
  auto_create_subnetworks = false
}

################## SUBNETS ################### 

#creation of 1st subnet
resource "google_compute_subnetwork" "subnet_proxy" {
  name          = var.proxy_subnet_name
  network       = google_compute_network.vpc_proxy_network.id
  ip_cidr_range = var.proxy_subnet_cidr
  region        = var.primary_region

  depends_on = [google_compute_network.vpc_proxy_network]
}

################## STATIC IPs ################### 

#reservation of primary BOCA static IP
resource "google_compute_address" "static_ip_reverse_proxy" {
  name         = "static-ip-reverse-proxy-01"
  network_tier = "STANDARD"
  region       = var.primary_region

  depends_on = [google_compute_network.vpc_proxy_network]
}

output "output_proxy_static_ip" {
  value = google_compute_address.static_ip_reverse_proxy.address
}

################## FIREWALL ################### 

#creation of firewall rules
resource "google_compute_firewall" "allow_https_proxy" {
  target_tags = ["https-server"]
  name        = "allow-https-proxy"
  network     = google_compute_network.vpc_proxy_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_https_port]
  }

  source_ranges = var.cloudflare_ingress_cidr
}

resource "google_compute_firewall" "allow_http_proxy" {
  target_tags = ["http-server"]
  name        = "allow-http-proxy"
  network     = google_compute_network.vpc_proxy_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_http_port]
  }

  source_ranges = var.cloudflare_ingress_cidr
}

resource "google_compute_firewall" "allow_ssh_proxy" {
  target_tags = ["ssh"]
  name        = "allow-ssh-proxy"
  network     = google_compute_network.vpc_proxy_network.id

  allow {
    protocol = "tcp"
    ports    = [var.firewall_ssh_port]
  }

  source_ranges = var.general_ingress_cidr
}

################## DEBUG ################### 
output "boca_primary_local_ip" {
  value = google_compute_instance.vm4.network_interface[0].network_ip
}

output "boca_secondary_local_ip" {
  value = google_compute_instance.vm5.network_interface[0].network_ip
}

output "animeitor_local_ip" {
  value = google_compute_instance.vm3_animeitor.network_interface[0].network_ip
}

################## VMs ################### 

resource "google_compute_instance" "reverse_proxy" {
  name         = var.proxy_instance_name
  machine_type = var.proxy_instance_shape
  zone         = var.primary_zone
  tags         = ["https-server", "http-server", "ssh"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = var.proxy_instance_disk_size
      type  = var.disk_type
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
  user-data = <<EOF
#cloud-config
write_files:
  - path: /var/lib/nginx/html/maintenance.html
    permissions: '0644'
    content: ${jsonencode(templatefile("${path.module}/maintenance.html.tpl", {
        admin_email = var.register_domain_email
        background_image_url = var.background_image_url
        message_maintenance = var.message_maintenance
    }))}

  - path: /etc/nginx/nginx.conf
    content: ${replace(jsonencode(templatefile("${path.module}/nginx.conf.tpl", {
        http_port               = var.firewall_http_port,
        https_port              = var.firewall_https_port,
        server_name_boca        = var.boca_server_name_url,
        server_name_animeitor   = var.animeitor_server_name_url,
        ssl_certificate         = "/etc/letsencrypt/live/${var.boca_server_name_url}/fullchain.pem",
        ssl_certificate_key     = "/etc/letsencrypt/live/${var.boca_server_name_url}/privkey.pem",
        boca_primary_local_ip   = "http://${google_compute_instance.vm4.network_interface[0].network_ip}",
        boca_secondary_local_ip = "http://${google_compute_instance.vm5.network_interface[0].network_ip}",
        animeitor_local_ip      = "http://${google_compute_instance.vm3_animeitor.network_interface[0].network_ip}",
    })), "$$", "$")}

runcmd:
  # 1. Preparar diretórios persistentes
  - mkdir -p /var/lib/letsencrypt
  - mkdir -p /var/lib/nginx/html

  # 2. Rodar Certbot (Geração inicial do certificado)
  - |
    docker run --rm --name certbot-gen \
      -v /var/lib/letsencrypt:/etc/letsencrypt \
      -p 80:80 \
      certbot/certbot certonly --standalone --non-interactive --agree-tos \
      -m ${var.register_domain_email} \
      -d ${var.boca_server_name_url} \
      -d ${var.animeitor_server_name_url}

  # 3. Rodar o Nginx com o volume do HTML incluído
  - |
    docker run -d \
      --name nginx-proxy \
      --restart always \
      -p 80:80 -p 443:443 \
      -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
      -v /var/lib/letsencrypt:/etc/letsencrypt:ro \
      -v /var/lib/nginx/html:/usr/share/nginx/html:ro \
      nginx:latest
EOF
}

depends_on = [google_compute_subnetwork.subnet_proxy, google_compute_address.static_ip_reverse_proxy]

}

output "proxy_public_ip" {
  value = google_compute_instance.reverse_proxy.network_interface[0].access_config[0].nat_ip
}