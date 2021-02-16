# Check Point Management Configuration
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is configuring an existing Check Point Management with few key components that are usually manually implemented in each GCP deployment.    
 


## Which are the components created / configured?
The project creates the following resources and combine them:
1. **Your Public IP host**: with the given information about your IP
2. **Dynamic Objects**: the objects created are *LocalGatewayInternal* and *LocalGatewayExternal*
3. **A localhost object**: to be used to configure Identity-Awareness Web API on the Cluster
4. **A dedicated policy package**: a new policy package to be applied to GCP gateways
5. **GCP Datacenter object**: thanks to the CloudGuard Controller and the Datacentr object we can use Azure-defined entities in the rulebase
6. **Onboard the GCP Cluster**: it connects the cluster to the management and configures the blades

## Which are the outputs of the project?
The projects doesn't give specific CLI outputs, the results of this script are visible on the management server (and the objects created visible via SmartConsole).

## How to use it
The two things that you need to do is first changing the __*terraform.tfvars*__ file located in this directory.
```hcl
# Customize your variables
# Put in this directory the JSON Key with the name cp-terraform.json
my-pubip    = "xx.xx.xx.xx"

mgmt-ip     = "xx.xx.xx.xx"
api-username = "xxxxxxxxxx"
api-password = "xxxxxxxxxx"

cluster-sic = "xxxxxxxxxx"
cluster-vip = "xx.xx.xx.xx"
ip-member-a = "xx.xx.xx.xx"
ip-member-b = "xx.xx.xx.xx"
```
And then adding under the project directory a JSON GCP Key with the name of __cp-terraform.json__ to gets access to your GCP Project.
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.   
Here you will also able to find the descriptions that explains what each variable is used for.
