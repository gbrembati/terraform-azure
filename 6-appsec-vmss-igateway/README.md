# CloudGuard AppSec Scalable Infinity Gateway Architecture
This Terraform project is meant to be used as a template to demonstrate or build a test environment.    
It creates an infrastructure composed of a North-hub and two spokes: one for the production and one for the staging.     
In the North-hub, an Appsec Virtual Machine Scale-Set is created, and inside the spokes is created a container instance of a vulnerable application ([Juice Shop](https://github.com/bkimminich/juice-shop)).

## Which are the components created?
The project creates the following resources and combine them:    
1. **Resource Groups**: for all the entities
2. **Vnet**: the north-hub and the two Vnets for the spokes
3. **Subnets**: inside the vNets
4. **Vnet peerings** (as shown in the design below)
5. **Routing table**: associated with the network in the spokes
6. **Appsec Infinity Gateway**: a Virtual Machine Scale-Set of AppSec gateways
7. **Container Instances**: in the spokes running a vulnerable application

## Prerequisite
Before you can start you would need to have an Appsec token that can be obtained with the following steps:
1. **Application Profile**: [Steps to create a new profile](/zimages/appsec-profile.jpg){target="_blank"}.
2. **Obtaining the Token**: [Steps to obtain a Token from a profile](/zimages/appsec-token.jpg){target="_blank"}.

## How to use it
The only thing that you need to do is changing the __*terraform.tfvars*__ file located in this directory.

```hcl
# Set in this file your deployment variables
azure-client-id     = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-client-secret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-tenant        = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
azure-subscription  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

location            = "France Central"
mydns-zone          = "<yourzone>.com"

# Have you ever deployed an Appsec Virtual Machine Scale-Set in this Subscription?
appsec-vmss-agreement = true

# AppSec Variables
appsec-name         = "vmss-appsec"
appsec-size         = "Standard_DS2_v2"
admin-pwd           = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
infinity-token      = "cp-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

appsec-vmss-min     = "2"
appsec-vmss-max     = "3" 
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.   
Here you will be also able to find the descriptions that explain what each variable is used for.

## Which are the outputs of the project?
The project gives as outputs the FQDNs of the Staging and Production Application.     
You will need to use them for the Infinity Portal configuration, in the INFINITY POLICY application.

## How to configure application in the Infinity Portal?
With the following steps you can create your application with the FQDN provided by Terraform as output:
1. **Staging Application**: [How to create the Staging application](/zimages/appsec-app-staging.jpg){target="_blank"}.
2. **Production Application**: [How to create the Production application](/zimages/appsec-app-prod.jpg){target="_blank"}.

After you have created both application, the Enforce of the changes has to be done.

## The infrastructure is created with the following design:
![Architectural Design](/zimages/schema-vmss-igappsec.jpg)