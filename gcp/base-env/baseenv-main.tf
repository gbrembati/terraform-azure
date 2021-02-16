terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.56.0"
    }
  }
}

# Configuration options
provider "google" {
  region        = var.gcp-region
  project       = var.gcp-project-id
  credentials   = file("cp-terraform.json")
}

# Creation of the two North VPCs
resource "google_compute_network" "vpc-north-ext" {
  mtu                     = var.vpc-mtu
  name                    = "vpc-${var.vpc-north}-ext"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "net-north-ext" {
  name          = "net-${var.vpc-north}-ext"
  ip_cidr_range = "172.16.0.0/22"
  region        = var.gcp-region
  private_ip_google_access = true
  network       = google_compute_network.vpc-north-ext.id
  depends_on    = [google_compute_network.vpc-north-ext]
}

resource "google_compute_network" "vpc-north-int" {
  mtu                     = var.vpc-mtu
  name                    = "vpc-${var.vpc-north}-int"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "net-north-int" {
  name          = "net-${var.vpc-north}-int"
  ip_cidr_range = "172.16.4.0/22"
  region        = var.gcp-region
  private_ip_google_access = true
  network       = google_compute_network.vpc-north-int.id
  depends_on    = [google_compute_network.vpc-north-int]
}

# Creation of the two South VPCs
resource "google_compute_network" "vpc-south-ext" {
  mtu                     = var.vpc-mtu
  name                    = "vpc-${var.vpc-south}-ext"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "net-south-ext" {
  name          = "net-${var.vpc-south}-ext"
  ip_cidr_range = "172.16.8.0/22"
  region        = var.gcp-region
  private_ip_google_access = true
  network       = google_compute_network.vpc-south-ext.id
  depends_on    = [google_compute_network.vpc-south-ext]
}

resource "google_compute_network" "vpc-south-int" {
  mtu                     = var.vpc-mtu
  name                    = "vpc-${var.vpc-south}-int"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "net-south-int" {
  name          = "net-${var.vpc-south}-int"
  ip_cidr_range = "172.16.12.0/22"
  region        = var.gcp-region
  private_ip_google_access = true
  network       = google_compute_network.vpc-south-int.id
  depends_on    = [google_compute_network.vpc-south-int]
}

# Creation of the Management VPCs
resource "google_compute_network" "vpc-mgmt" {
  mtu                     = var.vpc-mtu
  name                    = "vpc-${var.vpc-mgmt}"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "net-mgmt" {
  name          = "net-${var.vpc-mgmt}"
  ip_cidr_range = "172.16.16.0/22"
  region        = var.gcp-region
  private_ip_google_access = true
  network       = google_compute_network.vpc-mgmt.id
  depends_on    = [google_compute_network.vpc-mgmt]
}

# Creation of the two Spoke VPCs
resource "google_compute_network" "vpc-spoke" {
  count = length(var.vpc-spoke)

  mtu   = var.vpc-mtu
  name  = "vpc-spoke-${lookup(var.vpc-spoke,count.index)[0]}"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "net-spoke" {
  count = length(var.vpc-spoke)

  name          = "net-spoke-${lookup(var.vpc-spoke,count.index)[0]}"
  ip_cidr_range = lookup(var.vpc-spoke,count.index)[1]
  region        = var.gcp-region
  private_ip_google_access = true
  network       = google_compute_network.vpc-spoke[count.index].id
  depends_on    = [google_compute_network.vpc-spoke]  
}

# Creation of the peering between north-int and spoke
resource "google_compute_network_peering" "peering-north-to-spoke-dev" {
  count = length(var.vpc-spoke)

  name         = "peering-north-to-spoke-${lookup(var.vpc-spoke,count.index)[0]}"
  network      = google_compute_network.vpc-north-int.id
  peer_network = google_compute_network.vpc-spoke[count.index].id
  export_custom_routes = true

  depends_on   = [google_compute_network.vpc-spoke,google_compute_network.vpc-north-int]
}
resource "google_compute_network_peering" "peering-spoke-dev-to-north" {
  count = length(var.vpc-spoke)

  name         = "peering-spoke-${lookup(var.vpc-spoke,count.index)[0]}-to-north"
  network      = google_compute_network.vpc-spoke[count.index].id
  peer_network = google_compute_network.vpc-north-int.id
  import_custom_routes = true

  depends_on   = [google_compute_network.vpc-spoke,google_compute_network.vpc-north-int]
}

# Creation of the peering between south-int and spoke
resource "google_compute_network_peering" "peering-south-to-spoke-dev" {
  count = length(var.vpc-spoke)

  name         = "peering-south-to-spoke-${lookup(var.vpc-spoke,count.index)[0]}"
  network      = google_compute_network.vpc-south-int.id
  peer_network = google_compute_network.vpc-spoke[count.index].id
  export_custom_routes = true

  depends_on   = [google_compute_network.vpc-spoke,google_compute_network.vpc-south-int]
}
resource "google_compute_network_peering" "peering-spoke-dev-to-south" {
  count = length(var.vpc-spoke)

  name         = "peering-spoke-${lookup(var.vpc-spoke,count.index)[0]}-to-south"
  network      = google_compute_network.vpc-spoke[count.index].id
  peer_network = google_compute_network.vpc-south-int.id
  import_custom_routes = true
  
  depends_on   = [google_compute_network.vpc-spoke,google_compute_network.vpc-south-int]
}

resource "google_dns_managed_zone" "my-zone" {
  name        = "dns-zone-${var.my-dns-zone}"
  dns_name    = "gcp.${var.my-dns-zone}.it."
  description = "My Personal DNS zone"
}
resource "google_dns_record_set" "cpk-mgmt" {
  name = "${var.mgmt-name}.${google_dns_managed_zone.my-zone.dns_name}"
  type = "A"
  ttl  = 300
  managed_zone = google_dns_managed_zone.my-zone.name

  rrdatas = ["8.8.8.8"]
  depends_on = [google_dns_managed_zone.my-zone]
}