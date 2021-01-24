# Terraform Projects
This repository is a collection of Terraform automation projects, applicable to Azure, each of them is intended to be used as a template in a demonstration or to build a test environment.  In the directories, you will find a description of what the each project does and if you want (or need) to customize them, you can change defaults in the different __*name-variables.tf*__ files. 

## Which are the projects available?
The projects can be briefly described as follows:
1. **azure/base-environment**: It creates an environment based on the CloudGuard Blueprint's design principles
2. **azure/mgmt-configuration**: It configures existing Check Point management through APIs
3. **azure/vmss**: It creates a Virtual-Machine Scale-Sets to be used as outbound / inbound / east-west protection
4. **azure/vmss-vpn**: It creates a Virtual-Machine Scale-Sets with the Remote-Access components

## Do you want to see more? 
Check the Check Point official CloudGuard IaaS repository here: [CheckPointSW / CloudGuardIaaS](https://github.com/CheckPointSW/CloudGuardIaaS)
