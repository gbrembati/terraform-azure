# GCP BluePrint Architecture
This Terraform project is intended to be used as a template in a demonstration or to build a test environment.  
What it does is creating an infrastructure composed of a North-hub and South-hub and few spokes (the number can be changed).    
As per my deployments (made in London), this project creates all of the following in approximately __5 to 7 minutes__.   


## Which are the components created?
The project creates the following resources and combine them:
1. **Vnet**: north / south / mgmt / spokes
2. **Subnets**: inside the VPCs
4. **VPC peerings** (as shown in the design below) with the Export/Import Route
5. **Routes**: To connects to the different members from your IP
6. **Firewall Rules**: To allow the traffic needed between the VPCs
7. **Virtual machines**: A virtual machines in each of the spokes that contains an ubuntu VM w/ NGINX
8. **Check Point Management**: A management VM with the release R80.40
9. **Check Point Cluster HA**: A cluster of Check Point members in the south VPCs

## Which are the outputs of the project?
The project gives as outputs the Virtual IPs of the Ubuntu VMs.

## How to use it
The two things that you need to do is first changing the __*terraform.tfvars*__ file located in this directory.
```hcl
# Change here your deployment variables
# Put in this directory the JSON Key with the name cp-terraform.json
gcp-region      = "europe-west2"
gcp-project-id  = "xxxxxxxxxx"

my-pubip        = "xx.xx.xx.xx"

mgmt-name       = "ckp-mgmt"
mgmt-size       = "n1-standard-4"

cluster-name    = "ckp-cluster"
cluster-size    = "n1-standard-4"
cluster-sic     = "xxxxxxxxxx"
```
And then adding under the project directory a JSON GCP Key with the name of __cp-terraform.json__ to gets access to your GCP Project.
If you want (or need) to further customize other project details, you can change defaults in the different __*name-variables.tf*__ files.   
Here you will also able to find the descriptions that explains what each variable is used for.

## The infrastruction created with the following design:
![Architectural Design](/images/gcp-base-env.jpg)