# Check Point Management Configuration
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is configuring an existing Check Point Management with few key components that are usually manually implemented in each Azure deployment.    
 


## Which are the components created / configured?
The project creates the following resources and combine them:
1. **Your Public IP host**: with the given information about your IP
2. **Dynamic Objects**: the objects created are *LocalGatewayInternal* and *LocalGatewayExternal*
3. **Install the CME**: the Cloud Management Extension is used to dynamically provision VMSS Gateways
4. **A policy package**: a new policy package to be applied to azure gateways
5. **Azure Datacenter object**: thanks to the CloudGuard Controller and the Datacentr object we can use Azure-defined entities in the rulebase
6. **Update to a specified JHF**: it downloads and installs a specific Jumbo-Hotfix (by default : R80.40 Jumbo HotFix Take 89)

## Which are the outputs of the project?
The projects doesn't give specific CLI outputs, the results of this script are visible on the management server (and the objects created visible via SmartConsole).

## How to use it
The only thing that you need to do is changing the __*terraform.tfvars*__ file located in this directory.

```hcl
# Set in this file your deployment variables
my-pub-ip       = "xx.xx.xx.xx"

mgmt-ip         = "xx.xx.xx.xx"
api-username    = "xxxxx"
api-password    = "xxxxx"

new-policy-pkg  = "pkg-azure"
azure-dc-name   = "dc-azure"
last-jhf        = "Check_Point_R80_40_JUMBO_HF_Bundle_T89_sk165456_FULL.tgz" 
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.   
Here you will also able to find the descriptions that explains what each variable is used for.