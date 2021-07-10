# CloudGuard AppSec Scalable Infinity Gateway Architecture
This Terraform project is meant to be used as a template to demonstrate or build a test environment.    
It creates an infrastructure composed of a North-hub and two spokes: one for the production and one for the staging.     
In the North-hub, an Appsec Virtual Machine Scale-Set is created, and inside the spokes is created a container instance of a vulnerable application ([Juice Shop](https://github.com/bkimminich/juice-shop)).

## Which are the components created?
The project creates the following resources and combines them:

## Which are the outputs of the project?
The project gives as outputs the FQDNs of the Staging and Production Application. You will need to use them for the Infinity Portal configuration.     

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