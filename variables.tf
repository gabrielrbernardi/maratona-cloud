variable "project" {
  description = "GCLOUD project ID"
}

variable "default_shape_machine_primary" {
  description = "Default Machine Type"
}

variable "default_shape_machine_secondary" {
  description = "Default Secondary Machine Type"
}

variable "default_shape_machine_animeitor" {
  description = "Default Machine Type for Animeitor"
}

variable "primary_region" {
  description = "Default Region"
}

variable "secondary_region" {
  description = "Failover Region"
}

variable "primary_zone" {
  description = "Default Zone for primary resources"
}

variable "secondary_zone" {
  description = "Default Zone for secondary resources"
}

variable "name_animeitor_vm" {
  description = "Name for the Animeitor Machine"
}

variable "name_boca_primary" {
  description = "Name for the Boca Primary Machine"
}

variable "name_boca_secondary" {
  description = "Name for the Boca Secondary Machine"
}

variable "image_os_animeitor" {
  description = "OS Image name to be used with Animeitor"
}

variable "image_os_boca" {
  description = "OS Image name to be used with BOCA"
}

variable "disk_size_animeitor" {
  description = "Disk size for Animeitor VM in GB"
}

variable "new_disk_size_boca" {
  description = "Disk size for BOCA VMs in GB"
}

variable "disk_type" {
  description = "Disk type for all VMs"
}

variable "vpc_boca_network_name" {
  description = "Name for the VPC Network"
}

variable "vpc_animeitor_network_name" {
  description = "Name for the VPC Network for Animeitor"
}

variable "boca_primary_subnet_name" {
  description = "Name for the BOCA Primary Subnet"
}
variable "boca_primary_subnet_cidr" {
  description = "CIDR block for the BOCA Primary Subnet"
}

variable "boca_secondary_subnet_name" {
  description = "Name for the BOCA Secondary Subnet"
}

variable "boca_secondary_subnet_cidr" {
  description = "CIDR block for the BOCA Secondary Subnet"
}

variable "animeitor_subnet_name" {
  description = "Name for the Animeitor Subnet"
}

variable "animeitor_subnet_cidr" {
  description = "CIDR block for the Animeitor Subnet"
}

variable "safety_ingress_cidr" {
  description = "A list for CIDR blocks for safety ingress rules"
}

variable "firewall_ssh_port" {
  description = "Port number for SSH access in firewall rules"
}

variable "firewall_http_port" {
  description = "Port number for HTTP access in firewall rules"
}

variable "firewall_https_port" {
  description = "Port number for HTTPS access in firewall rules"
}

variable "firewall_postgresql_port" {
  description = "Port number for PostgreSQL access in firewall rules"
}