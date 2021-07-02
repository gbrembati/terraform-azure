# Azure BluePrint Architecture
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is creating a simple infrastructure composed of two vNets, the first contains a Check Point R80.40 Management and the second that includes a Check Point Cluster.    
As per my deployments (made in France Central), this project creates all of the following in less than __10 minutes__.   


## Which are the components created?
The project creates the following resources and combine them:
1. **Resource Groups**: for the vnets, the management and the cluster
2. **Vnet**: north / mgmt
3. **Subnets**: inside the vNets
4. **Vnet peerings** (as shown in the design below)
5. **Routing table**: associated with the web subnet in the north
6. **Rules** for the routing tables created
7. **Network Security Groups**: associated with the Check Point Management
8. **NSG Rules** inside the differents NSGs: to prevent undesired connections
9. **Virtual machines**: A Check Point R80.40 Management and nginx machines in the spokes 
10. **Public IPs**: associated with the management and the spoke VMs)
11. **Set the FQDN** with a schema: pub-"vmname"-"specified-suffix"."azure-location".cloudapp.azure.com

## Which are the outputs of the project?
The project gives the following outputs once is created

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
Here you will also able to find the descriptions that explains what each variable is used for.

## The infrastruction created with the following design:
![Architectural Design](/zimages/schema-base-env.jpg)