# Azure BluePrint Architecture
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.    
What it does is creating an infrastructure composed of a North-hub and two spokes: one for the production and one for the staging.    
Inside the North-hub an Appsec Virtual Machine Scale-Set and in the spokes a cointainer instance of a vulnerable application.    

## Which are the components created?
The project creates the following resources and combine them:


## Which are the outputs of the project?
The project gives the outputs of the FQDN of the Staging and Production Application to be configured inside the Infinity Portal.

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
Here you will also able to find the descriptions that explains what each variable is used for.

## The infrastruction created with the following design:
![Architectural Design](/zimages/schema-vmss-appsec.jpg)