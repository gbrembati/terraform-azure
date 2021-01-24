# Check Point Virtual-Machine Scale-Set
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is creating a new Check Point Virtual-Machine Scale-Set deployment of cloudguard gateway and the required configurations onto the Management Server.   
__One quick warning before you start__: this projects also configures the CME on the management server, with the __*init command*__.   
If you use it on a management server where the CME has already been configured this would result in loosing privious configuration, if you are in this case you just need to add the template to the existing configuration. So either commend this portion of the code in the *vmss-main.tf* file or change the commands that is given to the management.


## Which are the components created / configured?
The project creates the following resources and combine them:
1. **Resource group**: which contains all the components needed for the VMSS
2. **LoadBalancers**: both in the Frontend and in the Backend
3. **Virtual Machine Scale-sets**: where the gateways will be instanced
4. **VMSS Scaling threshold**: with their default values
5. **CloudGuard Gateways**: members of the VMSS
6. **Configure the CME**: it connects to the management and configures it with autoprov-cfg command


## Which are the outputs of the project?
The projects doesn't give specific CLI outputs, the results of this script is that the gateways will be instanced and they will be onboarded by the management server (visible via SmartConsole).

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
location                = "francecentral"

# VMSS details
vmss-sku-enabled        = true
vmss-version            = "r8040"
vmss-name               = "xxxxx"
vmss-password           = "xxxxx"
vmss-min-members        = "x"
vmss-max-members        = "x"
vmss-zones-number       = "x"
vmss-vnet               = "xxxxx"
vmss-template           = "xxxxx"
vmss-admin-alert        = "xxxxx"
vmss-vmsize             = "Standard_DS2_v2"
vmss-sic                = "xxxxx"

# Management details
mgmt-name               = "xxxxx"
mgmt-ip                 = "xx.xx.xx.xx"
api-username            = "xxxxx"
api-password            = "xxxxx"
new-policy-pkg          = "xxxxx"
mgmt-controller         = "xxxxx"
```
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.   
Here you will also able to find the descriptions that explains what each variable is used for.