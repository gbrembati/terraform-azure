terraform {
  required_providers {
    checkpoint = {
      source = "CheckPointSW/checkpoint"
      version = "1.0.5"
    }
  }
}

# Connecting to ckpmgmt
provider "checkpoint" {
    server = var.mgmt-ip
    username = var.api-username
    password = var.api-password
    context = var.provider-context
}

# Create the host-object with your public IP
resource "checkpoint_management_host" "my-public-ip" {
  name = "my-public-ip"
  ipv4_address = var.my-pub-ip
  color = "blue"
}

# Create the dynamic-obj: LocalGatewayInternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-int" {
  name = "LocalGatewayInternal"
  color = "blue"
}

# Create the dynamic-obj: LocalGatewayExternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-ext" {
  name = "LocalGatewayExternal"
  color = "blue"
}

# Publish the session after the creation of the objects
resource "checkpoint_management_publish" "post-dc-publish" {
  depends_on = [checkpoint_management_host.my-public-ip,checkpoint_management_dynamic_object.dyn-obj-local-ext,
              checkpoint_management_dynamic_object.dyn-obj-local-int]
}

# Cloud Management Extension installation
resource "checkpoint_management_run_script" "script-cme" {
  script_name = "CME Install"
  script = file("cme_installation.sh")
  targets = [var.mgmt-name]
}

# Azure Datacenter
#resource "checkpoint_management_run_script" "dc-azure" {
#  script_name = "Install Azure DC"
#  script = "xxxx"
#  targets = [var.mgmt-name]
#}

# Patch the management to the chosen JHF
resource "checkpoint_management_install_software_package" "install-jhf" {
  name = var.chosen-jhf
  depends_on = [checkpoint_management_run_script.script-cme]
}
