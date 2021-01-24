variable "azure-client-id" {
    description = "Insert your application client-id"
    sensitive = true
} 
variable "azure-client-secret" {
    description = "Insert your application client-secret"
    sensitive = true
}
variable "azure-subscription" {
    description = "Insert your subscription-id"
    sensitive = true
}
variable "azure-tenant" {
    description = "Insert your active-directory-id"
    sensitive = true
}

variable "location" {
    description = "Choose where to deploy the environment"
    default = "francecentral"
}

variable "vmss-sku-enabled" {
    description = "Have you ever deployed a ckp gateway before? set to false if not"
    type = bool
    default = true
}
variable "vmss-version" {
    description = "Choose the version to deploy: either r8040 or r81"
    default = "r8040"
}

variable vmss-name {
    description = "Specify the name of the Scale-set"
    default = "cpvmss"
}
variable vmss-password {
    description = "Specify the password for the Scale-set VMs"
    sensitive = true
}
variable vmss-min-members {
    description = "Set the maximum number of instances"
    default = "2"
}
variable vmss-max-members {
    description = "Set the maximum number of instances"
    default = "5"
}
variable vmss-zones-number {
    description = "Set the desired number of Availability Zone to be used"
    default = 0
}

variable vmss-vnet {
    description = "Put the name of the vnet w/o the first V"
    default = "net-north"
}
variable vmss-template {
    description = "Specify CME template name"
    default = "az-template"
}
variable vmss-admin-alert {
    description = "Specify the email to be notified in case of Scale in/out event"
}

variable vmss-vmsize {
    description = "Set the vmss machine size"
    default = "Standard_DS2_v2"
}
variable vmss-sic {
    description = "Set the SIC that needs to be used from the management"
    sensitive = true
}

variable "mgmt-name" {
    description = "Put the hostname of your management"
    default = "ckpmgmt"
}
variable "mgmt-ip" {
    description = "Put the public IP address of your management"
}
variable "api-username" {
    default= "admin"
}
variable "api-password" {
    sensitive = true
}
variable "provider-context" {
    description = "It can be used either web_api or gaia_api"
    default= "web_api"
}
variable "new-policy-pkg" {
    description = "Define the name of your azure policy package"
    default = "pkg-azure"
}
variable "mgmt-controller" {
    description = "Define the name of the CME controller"
    default = "azurectrl"
}