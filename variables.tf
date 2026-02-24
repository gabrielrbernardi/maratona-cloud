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