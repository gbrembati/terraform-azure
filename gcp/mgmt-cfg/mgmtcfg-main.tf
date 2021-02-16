terraform {
  required_providers {
    checkpoint = {
      source = "CheckPointSW/checkpoint"
      version = ">= 1.3.0"
    }
  }
}

# Connecting to ckpmgmt
provider "checkpoint" {
    server = var.mgmt-ip
    username = var.api-username
    password = var.api-password
    context = var.provider-context
    timeout = "180"
}

# Create the localhost-object
resource "checkpoint_management_host" "localhost-ip" {
  name = "obj-localhost"
  comments = "Created by Terraform"
  ipv4_address = "127.0.0.1"
  color = "forest green"
}
# Create the host-object with your public IP
resource "checkpoint_management_host" "my-public-ip" {
  name = "obj-my-pubIP"
  comments = "Created by Terraform"
  ipv4_address = var.my-pubip
  color = "forest green"
}

# Create the dynamic-obj: LocalGatewayInternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-int" {
  name = "LocalGatewayInternal"
  comments = "Created by Terraform"
  color = "forest green"
}

# Create the dynamic-obj: LocalGatewayExternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-ext" {
  name = "LocalGatewayExternal"
  comments = "Created by Terraform"
  color = "forest green"
}
# Create a new policy package
resource "checkpoint_management_package" "gcp-policy-pkg" {
  name = var.new-policy-pkg
  comments = "Created by Terraform"
  access = true
  threat_prevention = true
  color = "forest green"
}

# Create the GCP Cluster
resource "checkpoint_management_run_script" "gcp-cluster" {
  script_name = "Connect GCP Cluster"
  script = "mgmt_cli add simple-cluster name 'ckp-cluster' ipv4-address '${var.cluster-vip}' version 'R80.40' firewall true ips true anti-bot true anti-virus true interfaces.1.name 'eth0' interfaces.1.interface-type 'private' interfaces.1.topology 'EXTERNAL' interfaces.2.name 'eth1' interfaces.2.interface-type 'sync' interfaces.2.topology 'INTERNAL' interfaces.3.name 'eth2' interfaces.3.interface-type 'private' interfaces.3.topology 'INTERNAL' members.1.name 'ckp-cluster-a' members.1.one-time-password '${var.cluster-sic}' members.1.ip-address '${var.ip-member-a}' members.1.interfaces.1.name 'eth0' members.1.interfaces.1.ip-address '172.16.8.4' members.1.interfaces.1.network-mask '255.255.252.0' members.1.interfaces.2.name 'eth1' members.1.interfaces.2.ip-address '172.16.16.3' members.1.interfaces.2.network-mask '255.255.252.0' members.1.interfaces.3.name 'eth2' members.1.interfaces.3.ip-address '172.16.12.4' members.1.interfaces.3.network-mask '255.255.252.0' members.2.name 'ckp-cluster-b' members.2.one-time-password '${var.cluster-sic}' members.2.ip-address '${var.ip-member-b}' members.2.interfaces.1.name 'eth0' members.2.interfaces.1.ip-address '172.16.8.5' members.2.interfaces.1.network-mask '255.255.252.0' members.2.interfaces.2.name 'eth1' members.2.interfaces.2.ip-address '172.16.16.4' members.2.interfaces.2.network-mask '255.255.252.0' members.2.interfaces.3.name 'eth2' members.2.interfaces.3.ip-address '172.16.12.5' members.2.interfaces.3.network-mask '255.255.252.0' --format json color 'forest green' comments 'Created by Terraform' --user '${var.api-username}' --password '${var.api-password}' --version '1.6'"
  targets = ["${var.mgmt-name}-vm"]
}

# Create the GCP Datacenter
resource "checkpoint_management_run_script" "dc-gcp" {
  script_name = "Install GCP DataCenter"
  script = "mgmt_cli add data-center-server name '${var.gcp-dc-name}' type 'gcp' authentication-method 'key-authentication' private-key ${filebase64("cp-terraform.json")} --format json color 'forest green' comments 'Created by Terraform' --user '${var.api-username}' --password '${var.api-password}' --version '1.6'"
  targets = ["${var.mgmt-name}-vm"]
  depends_on = [checkpoint_management_run_script.gcp-cluster]
}

# Publish the session after the creation of the objects
resource "checkpoint_management_publish" "post-dc-publish" {
  depends_on = [checkpoint_management_host.localhost-ip, checkpoint_management_host.my-public-ip,checkpoint_management_dynamic_object.dyn-obj-local-ext, checkpoint_management_dynamic_object.dyn-obj-local-int,checkpoint_management_package.gcp-policy-pkg, checkpoint_management_run_script.dc-gcp, checkpoint_management_run_script.gcp-cluster]
}