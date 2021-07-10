terraform {
  required_providers {
    checkpoint = {
      source = "CheckPointSW/checkpoint"
      version = "1.3.0"
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

# Create the host-object with your public IP
resource "checkpoint_management_host" "my-public-ip" {
  name = "my-public-ip"
  comments = "Created by Terraform"
  ipv4_address = var.my-pub-ip
  color = "sky blue"
}

# Create the dynamic-obj: LocalGatewayInternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-int" {
  name = "LocalGatewayInternal"
  comments = "Created by Terraform"
  color = "sky blue"
}

# Create the dynamic-obj: LocalGatewayExternal
resource "checkpoint_management_dynamic_object" "dyn-obj-local-ext" {
  name = "LocalGatewayExternal"
  comments = "Created by Terraform"
  color = "sky blue"
}

# Cloud Management Extension installation
resource "checkpoint_management_run_script" "script-cme" {
  script_name = "CME Install"
  script = file("cme_installation.sh")
  targets = [var.mgmt-name]
}

# Create a new policy package
resource "checkpoint_management_package" "azure-policy-pkg" {
  name = var.new-policy-pkg
  comments = "Created by Terraform"
  access = true
  threat_prevention = true
  color = "sky blue"
  depends_on = [checkpoint_management_run_script.dc-azure]
}

# Publish the session after the creation of the objects
resource "checkpoint_management_publish" "post-dc-publish" {
  depends_on = [checkpoint_management_host.my-public-ip,checkpoint_management_dynamic_object.dyn-obj-local-ext,
         checkpoint_management_dynamic_object.dyn-obj-local-int,checkpoint_management_package.azure-policy-pkg]
}

# Create the Azure Datacenter
resource "checkpoint_management_run_script" "dc-azure" {
  script_name = "Install Azure DC"
  script = "mgmt_cli add data-center-server name '${var.azure-dc-name}' type 'azure' authentication-method 'service-principal-authentication' application-id '${var.azure-client-id}' application-key '${var.azure-client-secret}' directory-id '${var.azure-tenant}' color 'sky blue' comments 'Created by Terraform' --user '${var.api-username}' --password '${var.api-password}' --version '1.6'"
  targets = [var.mgmt-name]
  depends_on = [checkpoint_management_run_script.script-cme]
}

# Create the Azure Active Directory
resource "checkpoint_management_run_script" "ad-azure" {
  count = var.mgmt-r81 ? 1 : 0
  script_name = "Connect Azure Active Directory"
  script = "mgmt_cli add azure-ad name '${var.azure-ad-name}' authentication-method 'service-principal-authentication' application-id '${var.azure-client-id}' application-key '${var.azure-client-secret}' directory-id '${var.azure-tenant}' color 'sky blue' comments 'Created by Terraform' --user '${var.api-username}' --password '${var.api-password}' --version '1.7'" 
  targets = [var.mgmt-name]
}

# Install the latest GA Jumbo Hotfix 
resource "checkpoint_management_run_script" "management-jhf-install" {
  script_name = "Download & Install latest JHF"
  script = "clish -c 'installer agent update not-interactive' \n clish -c 'installer check-for-updates not-interactive' \n clish -c 'installer download-and-install '${var.last-jhf}' not-interactive'"
  targets = [var.mgmt-name]
  depends_on = [checkpoint_management_run_script.dc-azure]
}