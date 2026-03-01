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

variable "cloudflare_ingress_cidr" {
  description = "A list for CIDR blocks for Cloudflare IP addresses"
}

variable "general_ingress_cidr" {
  description = "A list for CIDR blocks for non-safety ingress rules"
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

variable "proxy_vpc_name" {
  description = "Name for the Proxy VPC"
}

variable "proxy_subnet_name" {
  description = "Name for the Proxy Subnet"
}

variable "proxy_subnet_cidr" {
  description = "CIDR block for the Proxy Subnet"
}

variable "proxy_instance_name" {
  description = "Name for the Proxy VM instance"
}

variable "proxy_instance_shape" {
  description = "Machine type for the Proxy VM instance"
}

variable "proxy_instance_disk_size" {
  description = "Disk size for the Proxy VM instance in GB"
}

variable "domain_name" {
  description = "Domain name for the reverse proxy configuration"
  default     = "example.com"
}

variable "boca_ip" {
  description = "Static IP address for BOCA VM"
  default     = "8.8.8.8"
}

variable "animeitor_ip" {
  description = "Static IP address for Animeitor VM"
  default     = "8.8.8.8"
}

variable "peering_proxy_to_boca_name" {
  description = "Name for the VPC peering connection from Proxy to BOCA"
}

variable "peering_boca_to_proxy_name" {
  description = "Name for the VPC peering connection from BOCA to Proxy"
}

variable "peering_proxy_to_animeitor_name" {
  description = "Name for the VPC peering connection from Proxy to Animeitor"
}

variable "peering_animeitor_to_proxy_name" {
  description = "Name for the VPC peering connection from Animeitor to Proxy"
}

variable "boca_server_name_url" {
  description = "Server name to be used in the reverse proxy configuration for BOCA. e.g. boca.your-domain.com"
}

variable "animeitor_server_name_url" {
  description = "Server name to be used in the reverse proxy configuration for Animeitor. e.g. animeitor.your-domain.com"
}

variable "register_domain_email" {
  description = "The email user to be used to register the domain"
}