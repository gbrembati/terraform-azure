# Azure BluePrint Architecture
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is creating an infrastructure composed of a North-hub and South-hub and few spokes (the number can be changed).   
This projects makes use of the __*azurerm*__ providers.

## Which are the components created?
The project creates the following resources and combine them:
1. **Resource Groups**: for the vnets, the management and the spokes
2. **Vnet**: north / south / mgmt / spokes
3. **Subnets**: inside the vents
4. **Vnet peerings** (as shown in the design below)
5. **Routing table**: associated with the network in the spokes
6. **Rules** for the routing tables created
7. **Network Security Groups**: associated with nets and VMs
8. **NSG Rules** inside the differents NSGs: to prevent undesired connections
9. **Virtual machines**: A Check Point R80.40 Management and nginx machines in the spokes 
10. **Public IPs**: associated with the management and the spoke VMs)
11. **Set the FQDN** with a schema: pub-"vmname"-"specified-suffix"."azure-location".cloudapp.azure.com

## How to use it
The only thing that you need to do is changing the __*terraform.tfvars*__ file located in this directory.

```hcl
# Set in this file your deployment variables
# Specify the Azure values
azure-client-id     = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-client-secret = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-subscription  = "xxxxx-xxxxx-xxxxx-xxxxx"
azure-tenant        = "xxxxx-xxxxx-xxxxx-xxxxx"

# Specify where you want to deploy it and where you are coming from
location                = "France Central"
my-pub-ip               = "x.x.x.x/32"

# Management details
mgmt-sku-enabled        = true
mgmt-dns-suffix         = "xxxxx"
mgmt-admin-pwd          = "xxxxx"

# VMspoke details
vmspoke-sku-enabled     = true
vmspoke-usr             = "xxxxx"
vmspoke-pwd             = "xxxxx"
spokes-default-gateway  = "172.16.1.4" 
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.

## The infrastruction created with the following design:
![Architectural Design](/images/schema-base-env.jpg)