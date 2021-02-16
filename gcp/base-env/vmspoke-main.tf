
resource "google_compute_route" "default" {
  count = length(var.vpc-spoke)
  name        = "route-vmspoke-${lookup(var.vpc-spoke,count.index)[0]}-to-my-ip"
  dest_range  = var.my-pubip
  network     = google_compute_network.vpc-spoke[count.index].name
  next_hop_gateway = "default-internet-gateway"
  priority    = 100
  depends_on = [google_compute_network.vpc-spoke]
}

# Firewall rule to allow https traffic
resource "google_compute_firewall" "allow-https" {
  count = length(var.vpc-spoke)
  name = "vmspoke-${lookup(var.vpc-spoke,count.index)[0]}-allow-https"
  network = google_compute_network.vpc-spoke[count.index].name
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  target_tags = ["webserver"]
  depends_on = [google_compute_network.vpc-spoke]
}

# Firewall rule to allow ssh traffic
resource "google_compute_firewall" "allow-ssh" {
  count = length(var.vpc-spoke)
  name = "vmspoke-${lookup(var.vpc-spoke,count.index)[0]}-allow-ssh"
  network = google_compute_network.vpc-spoke[count.index].name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ubuntu"]
  depends_on = [google_compute_network.vpc-spoke]
}

resource "google_compute_address" "pub-ip-vmspoke" {
  count = length(var.vpc-spoke)
  name = "vm-ubuntu-spoke-${lookup(var.vpc-spoke,count.index)[0]}"
  region = var.gcp-region
  depends_on = [google_compute_network.vpc-spoke]
}

# Creation of the VM
resource "google_compute_instance" "vm-ubuntu-spoke" {
  count = length(var.vpc-spoke)

  name = "vm-ubuntu-spoke-${lookup(var.vpc-spoke,count.index)[0]}"
  machine_type = "f1-micro"
  zone = "${var.gcp-region}-a"
  tags = ["ubuntu","webserver"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  } 
  metadata_startup_script = "sudo apt-get -y update; sudo apt-get -y dist-upgrade ; sudo apt-get -y install nginx"

  network_interface {
    network = google_compute_network.vpc-spoke[count.index].name
    subnetwork = google_compute_subnetwork.net-spoke[count.index].name
    access_config {
      nat_ip = google_compute_address.pub-ip-vmspoke[count.index].address
    }
  }

  depends_on = [google_compute_subnetwork.net-spoke,google_compute_address.pub-ip-vmspoke]
}
output "ubuntu-vm-public-ip" {
  value = google_compute_instance.vm-ubuntu-spoke[*].network_interface.0.access_config.0.nat_ip
}