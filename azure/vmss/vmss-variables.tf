variable "azure-client-id" {
    description = "Insert your application client-id"
    default = "xxxxx"
} 
variable "azure-client-secret" {
    description = "Insert your application client-secret"
    default = "xxxxx"
}
variable "azure-subscription" {
    description = "Insert your subscription-id"
    default = "xxxxx"
}
variable "azure-tenant" {
    description = "Insert your active-directory-id"
    default = "xxxxx"
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
    default = "xxxxx"
}
variable vmss-max-members {
    description = "Set the maximum number of instances"
    default = "3"
}
variable vmss-zones-number {
    description = "Set the desired number of Availability Zone to be used"
    default = "2"
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
    default = "xxxxx"
}
variable vmss-remoteaccess {
    description = "Choose if you want remote-access | yes or no"
    default = "no"
}
variable vmss-dns-resource-id {
    description = "If choosen no in the vmss-remoteaccess var leave it blank"
    default = ""
}
variable vmss-dns-host-a {
    description = "If choosen no in the vmss-remoteaccess var leave it blank"
    default = ""
}
variable "office-mode-net" {
    description = "Set the pool used with the office mode"
    default = "172.16.111.0/24"
}
variable "encryption-domain" {
    description = "Set the networks to be included in the encryption domain"
    default = "xxxxx"
}
variable "vpn-dns" {
    description = "Set the dns servers applied from the endpoint client"
    default = "xxxxx"
}

variable vmss-vmsize {
    description = "Set the vmss machine size"
    default = "Standard_DS2_v2"
}
variable vmss-sic {
    description = "Set the SIC that needs to be used from the management"
    default = "xxxxx"
}

variable "mgmt-name" {
    description = "Put the hostname of your management"
    default = "ckpmgmt"
}
variable "mgmt-ip" {
    description = "Put the public IP address of your management"
    default= "xx.xx.xx.xx"
}
variable "api-username" {
    default= "admin"
}
variable "api-password" {
    default= "xxxxx"
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