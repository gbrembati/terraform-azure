resource "google_deployment_manager_deployment" "deployment-mgmt" {
  name = var.mgmt-name
  target {
    config {
      content = <<DeploymentConfig
imports:
- path: gdm-cp-mgmt/check-point-vsec--byol.py
resources:
- name: check-point-vsec--byol
  type: check-point-vsec--byol.py
  properties:
    zone: ${var.gcp-region}-a
    machineType: ${var.mgmt-size}
    network: vpc-${var.vpc-mgmt}
    subnetwork: net-${var.vpc-mgmt}
    network_enableTcp: true
    network_tcpSourceRanges: ${var.my-pubip}/32
    network_enableGwNetwork: true
    network_gwNetworkSourceRanges: 0.0.0.0/0
    network_enableIcmp: true
    network_icmpSourceRanges: ${var.my-pubip}/32
    network_enableUdp: false
    network_udpSourceRanges: ''
    network_enableSctp: true
    network_sctpSourceRanges: ${var.my-pubip}/32
    network_enableEsp: false
    network_espSourceRanges: ''
    externalIP: Static
    installationType: R80.40 Management only
    diskType: pd-ssd
    bootDiskSizeGb: 100.0
    generatePassword: true
    allowUploadDownload: true
    enableMonitoring: false
    shell: /bin/bash
    instanceSSHKey: ''
    sicKey: ''
    managementGUIClientNetwork: ${var.my-pubip}/32
    numAdditionalNICs: 0.0
    additionalNetwork1: vpc-mgmt
    additionalSubnetwork1: net-mgmt
    externalIP1: None
    additionalNetwork2: vpc-mgmt
    additionalSubnetwork2: net-mgmt
    externalIP2: None
    additionalNetwork3: vpc-mgmt
    additionalSubnetwork3: net-mgmt
    externalIP3: None
    additionalNetwork4: vpc-mgmt
    additionalSubnetwork4: net-mgmt
    externalIP4: None
    additionalNetwork5: vpc-mgmt
    additionalSubnetwork5: net-mgmt
    externalIP5: None
    additionalNetwork6: vpc-mgmt
    additionalSubnetwork6: net-mgmt
    externalIP6: None
    additionalNetwork7: vpc-mgmt
    additionalSubnetwork7: net-mgmt
    externalIP7: None
DeploymentConfig
    }
    imports {
      name    = "c2d_deployment_configuration.json"
      content = file("gdm-cp-mgmt/c2d_deployment_configuration.json")
    }
    imports {
      name    = "check-point-vsec--byol.py"
      content = file("gdm-cp-mgmt/check-point-vsec--byol.py")
    }
    imports {
      name    = "check-point-vsec--byol.py.display"
      content = file("gdm-cp-mgmt/check-point-vsec--byol.py.display")
    }
    imports {
      name    = "check-point-vsec--byol.py.schema"
      content = file("gdm-cp-mgmt/check-point-vsec--byol.py.schema")
    }
    imports {
      name    = "common.py"
      content = file("gdm-cp-mgmt/common.py")
    }
    imports {
      name    = "default.py"
      content = file("gdm-cp-mgmt/default.py")
    }
    imports {
      name    = "images.py"
      content = file("gdm-cp-mgmt/images.py")
    }
    imports {
      name    = "password.py"
      content = file("gdm-cp-mgmt/password.py")
    }
    imports {
      name    = "resources/en-us/check-point-130x130.png"
      content = filebase64("gdm-cp-mgmt/resources/en-us/check-point-130x130.png")
    }
    imports {
      name    = "resources/en-us/check-point-64x64.png"
      content = filebase64("gdm-cp-mgmt/resources/en-us/check-point-64x64.png")
    }
    imports {
      name    = "test_config.yaml"
      content = file("gdm-cp-mgmt/test_config.yaml")
    }
  }
  depends_on = [google_compute_subnetwork.net-mgmt]
}