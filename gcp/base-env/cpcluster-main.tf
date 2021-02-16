
resource "google_compute_firewall" "allow-tcp-traffic-to-south" {
  name = "allow-tcp-traffic-to-south"
  network = google_compute_network.vpc-south-int.name
  allow {
    protocol = "tcp"
  }
  depends_on = [google_compute_network.vpc-south-int]
}
resource "google_compute_firewall" "allow-udp-traffic-to-south" {
  name = "allow-udp-traffic-to-south"
  network = google_compute_network.vpc-south-int.name
  allow {
    protocol = "udp"
  }
  depends_on = [google_compute_network.vpc-south-int]
}
resource "google_compute_firewall" "allow-icmp-traffic-to-south" {
  name = "allow-icmp-traffic-to-south"
  network = google_compute_network.vpc-south-int.name
  allow {
    protocol = "icmp"
  }
  depends_on = [google_compute_network.vpc-south-int]
}
resource "google_deployment_manager_deployment" "deployment-cluster" {
  name = "ckp-cluster"
  target {
    config {
      content = <<DeploymentConfig
imports:
- path: gdm-cp-cluster/check-point-cluster--byol.py
resources:
- name: check-point-cluster--byol
  type: check-point-cluster--byol.py
  properties:
    ha_version: R80.40 Cluster
    zoneA: ${var.gcp-region}-a
    zoneB: ${var.gcp-region}-b
    machineType: ${var.cluster-size}
    diskType: pd-ssd
    bootDiskSizeGb: 100.0
    instanceSSHKey: ''
    enableMonitoring: false
    managementNetwork: 172.16.16.2/32
    sicKey: ${var.cluster-sic}
    generatePassword: true
    allowUploadDownload: true
    shell: /bin/bash
    cluster-network-cidr: ''
    cluster-network-name: vpc-${var.vpc-south}-ext
    cluster-network-subnetwork-name: net-${var.vpc-south}-ext
    cluster-network_enableIcmp: true
    cluster-network_icmpSourceRanges: 0.0.0.0/0
    cluster-network_enableTcp: true
    cluster-network_tcpSourceRanges: 0.0.0.0/0
    cluster-network_enableUdp: true
    cluster-network_udpSourceRanges: 0.0.0.0/0
    cluster-network_enableSctp: true
    cluster-network_sctpSourceRanges: 0.0.0.0/0
    cluster-network_enableEsp: true
    cluster-network_espSourceRanges: 0.0.0.0/0
    mgmt-network-cidr: ''
    mgmt-network-name: vpc-${var.vpc-mgmt}
    mgmt-network-subnetwork-name: net-${var.vpc-mgmt}
    mgmt-network_enableIcmp: true
    mgmt-network_icmpSourceRanges: 0.0.0.0/0
    mgmt-network_enableTcp: true
    mgmt-network_tcpSourceRanges: 0.0.0.0/0
    mgmt-network_enableUdp: true
    mgmt-network_udpSourceRanges: 0.0.0.0/0
    mgmt-network_enableSctp: true
    mgmt-network_sctpSourceRanges: 0.0.0.0/0
    mgmt-network_enableEsp: false
    mgmt-network_espSourceRanges: ''
    numInternalNetworks: 1.0
    internal-network1-cidr: ''
    internal-network1-name: vpc-${var.vpc-south}-int
    internal-network1-subnetwork-name: net-${var.vpc-south}-int
    internal-network2-cidr: ''
    internal-network2-name: vpc-${var.vpc-south}-int
    internal-network2-subnetwork-name: net-${var.vpc-south}-int
    internal-network3-cidr: ''
    internal-network3-name: vpc-${var.vpc-south}-int
    internal-network3-subnetwork-name: net-${var.vpc-south}-int
    internal-network4-cidr: ''
    internal-network4-name: vpc-${var.vpc-south}-int
    internal-network4-subnetwork-name: net-${var.vpc-south}-int
    internal-network5-cidr: ''
    internal-network5-name: vpc-${var.vpc-south}-int
    internal-network5-subnetwork-name: net-${var.vpc-south}-int
    internal-network6-cidr: ''
    internal-network6-name: vpc-${var.vpc-south}-int
    internal-network6-subnetwork-name: net-${var.vpc-south}-int
DeploymentConfig
    }
    imports {
      name    = "c2d_deployment_configuration.json"
      content = file("gdm-cp-cluster/c2d_deployment_configuration.json")
    }
    imports {
      name    = "check-point-cluster--byol.py"
      content = file("gdm-cp-cluster/check-point-cluster--byol.py")
    }
    imports {
      name    = "check-point-cluster--byol.py.display"
      content = file("gdm-cp-cluster/check-point-cluster--byol.py.display")
    }
    imports {
      name    = "check-point-cluster--byol.py.schema"
      content = file("gdm-cp-cluster/check-point-cluster--byol.py.schema")
    }
    imports {
      name    = "common.py"
      content = file("gdm-cp-cluster/common.py")
    }
    imports {
      name    = "default.py"
      content = file("gdm-cp-cluster/default.py")
    }
    imports {
      name    = "images.py"
      content = file("gdm-cp-cluster/images.py")
    }
    imports {
      name    = "password.py"
      content = file("gdm-cp-cluster/password.py")
    }
    imports {
      name    = "resources/en-us/check-point-130x130.png"
      content = filebase64("gdm-cp-cluster/resources/en-us/check-point-130x130.png")
    }
    imports {
      name    = "resources/en-us/check-point-64x64.png"
      content = filebase64("gdm-cp-cluster/resources/en-us/check-point-64x64.png")
    }
    imports {
      name    = "resources/en-us/cluster-architecture.jpg"
      content = filebase64("gdm-cp-cluster/resources/en-us/cluster-architecture.jpg")
    }
    imports {
      name    = "test_config.yaml"
      content = filebase64("gdm-cp-cluster/test_config.yaml")
    }
  }
  depends_on = [google_compute_network_peering.peering-south-to-spoke-dev,google_compute_network_peering.peering-spoke-dev-to-south]
}