resource "google_compute_network_peering" "proxy_to_boca_peering" {
  name         = var.peering_proxy_to_boca_name
  network      = google_compute_network.vpc_proxy_network.self_link
  peer_network = google_compute_network.vpc_network.self_link

  depends_on = [google_compute_network.vpc_network, google_compute_network.vpc_proxy_network]
}

resource "google_compute_network_peering" "boca_to_proxy_peering" {
  name         = var.peering_boca_to_proxy_name
  network      = google_compute_network.vpc_network.self_link
  peer_network = google_compute_network.vpc_proxy_network.self_link

  depends_on = [google_compute_network.vpc_network, google_compute_network.vpc_proxy_network]
}

resource "google_compute_network_peering" "proxy_to_animeitor_peering" {
  name         = var.peering_proxy_to_animeitor_name
  network      = google_compute_network.vpc_proxy_network.self_link
  peer_network = google_compute_network.vpc_network_animeitor.self_link

  depends_on = [google_compute_network.vpc_network_animeitor, google_compute_network.vpc_proxy_network]
}

resource "google_compute_network_peering" "animeitor_to_proxy_peering" {
  name         = var.peering_animeitor_to_proxy_name
  network      = google_compute_network.vpc_network_animeitor.self_link
  peer_network = google_compute_network.vpc_proxy_network.self_link

  depends_on = [google_compute_network.vpc_network_animeitor, google_compute_network.vpc_proxy_network]
}

resource "google_compute_network_peering" "boca_to_animeitor_peering" {
  name         = var.peering_boca_to_animeitor_name
  network      = google_compute_network.vpc_network.self_link
  peer_network = google_compute_network.vpc_network_animeitor.self_link

  depends_on = [google_compute_network.vpc_network_animeitor, google_compute_network.vpc_proxy_network]
}

resource "google_compute_network_peering" "animeitor_to_boca_peering" {
  name         = var.peering_animeitor_to_boca_name
  network      = google_compute_network.vpc_network_animeitor.self_link
  peer_network = google_compute_network.vpc_network.self_link

  depends_on = [google_compute_network.vpc_network_animeitor, google_compute_network.vpc_proxy_network]
}
