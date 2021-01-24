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
