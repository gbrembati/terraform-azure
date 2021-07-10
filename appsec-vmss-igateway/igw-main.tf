# Accept the agreement for the mgmt-byol for R80.40
resource "azurerm_marketplace_agreement" "appsec-vmss-agreement" {
  count = var.appsec-vmss-agreement ? 0 : 1
  publisher = "checkpoint"
  offer = "infinity-gw"
  plan = "infinity-img"
}

# Create appsec resource group
resource "azurerm_resource_group" "rg-appsec-vmss" {
  name = "rg-${var.appsec-name}"
  location = var.location
}
resource "azurerm_resource_group_template_deployment" "template-deployment-appsec" {
  name                = "${var.appsec-name}-deploy"
  resource_group_name = azurerm_resource_group.rg-appsec-vmss.name
  deployment_mode     = "Complete"

  template_content    = file("files/appsec-vmss-template.json")
  parameters_content  = <<PARAMETERS
  {
    "location": {
        "value": "${azurerm_resource_group.rg-appsec-vmss.location}"
    },
    "vmName": {
        "value": "${var.appsec-name}"
    },
    "inboundSources": {
        "value": "0.0.0.0/0"
    },
    "authenticationType": {
        "value": "password"
    },
    "adminPassword": {
        "value": "${var.admin-pwd}"
    },
    "sshPublicKey": {
        "value": ""
    },
    "waapAgentToken": {
        "value": "${var.infinity-token}"
    },
    "waapAgentFog": {
        "value": ""
    },
    "adminEmail": {
        "value": ""
    },
    "availabilityZonesNum": {
        "value": 2
    },
    "vmSize": {
        "value": "${var.appsec-size}"
    },
    "diskType": {
        "value": "Standard_LRS"
    },
    "instanceCount": {
        "value": "${var.appsec-vmss-min}"
    },
    "maxInstanceCount": {
        "value": "${var.appsec-vmss-max}"
    },
    "instanceLevelPublicIP": {
        "value": "yes"
    },
    "elbResourceId": {
        "value": ""
    },
    "elbTargetBEAddressPoolName": {
        "value": ""
    },
    "deploymentMode": {
        "value": "ELBOnly"
    },
    "appLoadDistribution": {
        "value": "SourceIP"
    },
    "ilbResourceId": {
        "value": ""
    },
    "ilbTargetBEAddressPoolName": {
        "value": ""
    },
    "ilbLoadDistribution": {
        "value": "Default"
    },
    "bootstrapScript": {
        "value": ""
    },
    "sourceImageVhdUri": {
        "value": "noCustomUri"
    },
    "vnetNewOrExisting": {
        "value": "existing"
    },
    "virtualNetworkExistingRGName": {
        "value": "${azurerm_virtual_network.vnet-north.resource_group_name}"
    },
    "virtualNetworkName": {
        "value": "${azurerm_virtual_network.vnet-north.name}"
    },
    "virtualNetworkAddressPrefixes": {
        "value": [
            "${azurerm_virtual_network.vnet-north.address_space[0]}"
        ]
    },
    "subnet1Name": {
        "value": "${azurerm_subnet.net-north-frontend.name}"
    },
    "subnet1Prefix": {
        "value": "${azurerm_subnet.net-north-frontend.address_prefixes[0]}"
    },
    "subnet2Name": {
        "value": "${azurerm_subnet.net-north-backend.name}"
    },
    "subnet2Prefix": {
        "value": "${azurerm_subnet.net-north-backend.address_prefixes[0]}"
    },
    "subnet2StartAddress": {
        "value": "10.10.1.4"
    },
    "check_PointTags": {
        "value": {
            "provider": "30DE18BC-F9F6-4F22-9D30-54B8E74CFD5F"
        }
    },
    "sicKey": {
        "value": ""
    },
    "chooseVault": {
        "value": "none"
    },
    "existingKeyVaultRGName": {
        "value": "${azurerm_resource_group.rg-appsec-vmss.name}"
    },
    "keyVaultName": {
        "value": "vault-${var.appsec-name}"
    },
    "numberOfCerts": {
        "value": 0
    },
    "firstCertificate": {
        "value": ""
    },
    "firstCertDescription": {
        "value": ""
    },
    "firstCertPassword": {
        "value": ""
    },
    "secondCertificate": {
        "value": ""
    },
    "secondCertDescription": {
        "value": ""
    },
    "secondCertPassword": {
        "value": ""
    },
    "thirdCertificate": {
        "value": ""
    },
    "thirdCertDescription": {
        "value": ""
    },
    "thirdCertPassword": {
        "value": ""
    },
    "fourthCertificate": {
        "value": ""
    },
    "fourthCertDescription": {
        "value": ""
    },
    "fourthCertPassword": {
        "value": ""
    },
    "fifthCertificate": {
        "value": ""
    },
    "fifthCertDescription": {
        "value": ""
    },
    "fifthCertPassword": {
        "value": ""
    }
  }
  PARAMETERS 
  depends_on = [azurerm_resource_group.rg-appsec-vmss,azurerm_subnet.net-north-frontend,azurerm_subnet.net-north-backend]
}

resource "azurerm_dns_a_record" "juiceshop-prod-record" {
  name                = "juiceshop-prod"
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  records             = [jsondecode(azurerm_resource_group_template_deployment.template-deployment-appsec.output_content).applicationAddress.value]
  depends_on = [azurerm_resource_group_template_deployment.template-deployment-appsec]
}
resource "azurerm_dns_a_record" "juiceshop-staging-record" {
  name                = "juiceshop-staging"
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  records             = [jsondecode(azurerm_resource_group_template_deployment.template-deployment-appsec.output_content).applicationAddress.value]
  depends_on          = [azurerm_resource_group_template_deployment.template-deployment-appsec]
}

output "webapp-production-fqdn" {
    value = azurerm_dns_a_record.juiceshop-prod-record.fqdn
} 
output "webapp-staging-fqdn" {
    value = azurerm_dns_a_record.juiceshop-staging-record.fqdn
}