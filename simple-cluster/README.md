# Azure Simple Cluster Architecture
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is creating a simple infrastructure composed of two vNets. The first contains a Check Point R80.40 Management, and the second that includes a Check Point R80.40 Cluster.    
As per my deployments (made in France Central), this project creates all of the following in less than __10 minutes__.   


## Which are the components created?
The project creates the following resources and combines them:
1. **Resource Groups**: for the vnets, the management and the cluster
2. **Vnet**: north / mgmt
3. **Subnets**: inside the vNets
4. **Vnet peerings** (as shown in the design below)
5. **Routing table**: associated with the web subnet in the north
6. **Rules** for the routing tables created
7. **Network Security Groups**: associated with the Check Point Management
8. **NSG Rules** inside the differents NSGs: to prevent undesired connections
9. **Virtual machines**: A Check Point R80.40 Management and a Check Point R80.40 Cluster 
10. **Public IPs**: associated with the management and the Cluster VMs

## Which are the outputs of the project?
The project gives the management public FQDN once it is created.

## How to use it
The only thing that you need to do is changing the __*terraform.tfvars*__ file located in this directory.

```hcl

# Set in this file your deployment variables
azure-client-secret             = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-client-id                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-tenant                    = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-subscription              = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
location                        = "France Central"

mgmt-name                       = "ckpmgmt"
mgmt-size                       = "Standard_D3_v2"
my-pub-ip                       = "xx.xx.xx.xx/32"

resource_group_name             = "rg-cpcluster"
cluster_name                    = "cpcluster"
vm_size                         = "Standard_D2_v2"
availability_type               = "Availability Zone"

admin_password                  = "xxxxxxxxxxxxx"
sic_key                         = "xxxxxxxxxxxxx"
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.   
Here you will be also able to find the descriptions that explain what each variable is used for.

## The infrastructure is created with the following design:
![Architectural Design](/zimages/schema-simple-cluster.jpg)