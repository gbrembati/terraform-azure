terraform {
  required_providers {
    checkpoint = {
      source = "CheckPointSW/checkpoint"
      version = "1.3.0"
    }
  }
}

# Configuration of Terraform with Azure environment variables
provider "azurerm" {
  features { }
  client_id = var.azure-client-id
  client_secret = var.azure-client-secret
  subscription_id = var.azure-subscription
  tenant_id = var.azure-tenant
}

# Create vmss resource group
resource "azurerm_resource_group" "rg-ckpmgmt" {
  name = "rg-${var.vmss-name}"
  location = var.location
}

# Deploy the vmss template w/ remote-access
resource "azurerm_resource_group_template_deployment" "template-deployment-vmss" {
  name                = "${var.vmss-name}-deploy"
  resource_group_name = "rg-${var.vmss-name}"
  deployment_mode     = "Complete"
  depends_on = [azurerm_resource_group.rg-ckpmgmt]

  template_content    = file("${path.module}/template.json")
  parameters_content  = <<PARAMETERS
  {
        "location": { 
            "value": "${var.location}" 
        },
        "authenticationType": { 
            "value": "password" 
        },
        "adminPassword": { 
            "value": "${var.vmss-password}"
        },
        "upgrading": { 
            "value": "no" 
        },
        "vmName": { 
            "value": "${var.vmss-name}" 
        },
        "instanceCount": { 
            "value": "2"
        },
        "maxInstanceCount": { 
            "value": "${var.vmss-max-members}" 
        },
        "managementServer": { 
            "value": "${var.mgmt-name}" 
        },
        "configurationTemplate": { 
            "value": "${var.vmss-template}"
        },
        "adminEmail": {
            "value": "${var.vmss-admin-alert}"
        },
        "deploymentMode": { 
            "value": "Standard"
        },
        "instanceLevelPublicIP": { 
            "value": "yes" 
        },
        "mgmtInterfaceOpt1": { 
            "value": "eth1-private" 
        },
        "appLoadDistribution": { 
            "value": "Default" 
        },
        "ilbLoadDistribution": { 
            "value": "Default" 
        },
        "availabilityZonesNum": { 
            "value": ${var.vmss-zones-number}
        },
        "remoteAccessVpn": { 
            "value": "${var.vmss-remoteaccess}" 
        },
        "dnsZoneResourceId": { 
            "value": "${var.vmss-dns-resource-id}"
        },
        "dnsZoneRecordSetName": {
            "value": "${var.vmss-dns-host-a}"
        },
        "customMetrics": {
            "value": "yes"
        },
        "cloudGuardVersion": { 
            "value": "R80.40 - Bring Your Own License" 
        },
        "vmSize": { 
            "value": "${var.vmss-vmsize}"
        },
        "sicKey": { 
            "value": "${var.vmss-sic}"
        },
        "bootstrapScript": { 
            "value": "" 
        },
        "allowDownloadFromUploadToCheckPoint": { 
            "value": "true" 
        },
        "diskType": { 
            "value": "Standard_LRS"
        },
        "sourceImageVhdUri": { 
            "value": "noCustomUri"
        },
        "virtualNetworkName": { 
            "value": "v${var.vmss-vnet}"
        },
        "virtualNetworkAddressPrefixes": { 
            "value": ["172.16.0.0/22"] 
        },
        "vnetNewOrExisting" : { 
            "value": "existing" 
        },
        "virtualNetworkExistingRGName": { 
            "value": "rg-v${var.vmss-vnet}"
        },
        "subnet1Name": { 
            "value": "${var.vmss-vnet}-frontend"
        },
        "subnet1Prefix": { 
            "value": "172.16.0.0/24"
        },
        "subnet2Name": { 
            "value": "${var.vmss-vnet}-backend" 
        },
        "subnet2Prefix": { 
            "value": "172.16.1.0/24" 
        },
        "subnet2StartAddress": { 
            "value": "172.16.1.4" 
        }
  }  
  PARAMETERS
}

# Connecting to ckpmgmt
provider "checkpoint" {
    server = var.mgmt-ip
    username = var.api-username
    password = var.api-password
    context = var.provider-context
    timeout = "180"
}

# Configure the CME: autoprov-cfg service w/ remote-access
resource "checkpoint_management_run_script" "management-cme-remote-config" {
  script_name = "CME Configuration for VMSS w/ Remote-VPN"
  script = "yes | autoprov_cfg init Azure -mn ${var.mgmt-name} -tn ${var.vmss-template} -otp ${var.vmss-sic} -ver R80.40 -po ${var.new-policy-pkg} -cn ${var.mgmt-controller} -sb ${var.azure-subscription} -at ${var.azure-tenant} -aci ${var.azure-client-id} -acs ${var.azure-client-secret} -om '${var.office-mode-net}' -ed '${var.encryption-domain}' -dns '${var.vpn-dns}'"
  targets = [var.mgmt-name]
  depends_on = [azurerm_resource_group_template_deployment.template-deployment-vmss]
}