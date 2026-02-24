terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
  backend "gcs" {
    bucket = "maratona-tfstate"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project
  region  = var.primary_region
  zone    = var.primary_zone
}
