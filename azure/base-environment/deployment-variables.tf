
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
    default = "France Central"
}

variable "my-pub-ip" {
    description = "Put your public-ip"
    default = "x.x.x.x/32"
}

variable "mgmt-sku-enabled" {
    description = "Have you ever deployed a ckp management before? set to false if not"
    type = bool
    default = true
}
variable "mgmt-dns-suffix" {
    description = "This is the public DNS suffix of your mgmt FQDN"
    default = "xxxxx"
}

variable "mgmt-admin-pwd" {
    description = "Choose your management admin password"
    default = "xxxxx"
}

variable "deploy-vmspoke" {
    description = "Do you want to deploy test VMs inside the spokes?"
    type = bool
    default = true
}

variable "vmspoke-sku-enabled" {
    description = "Have you ever deployed this vm spoke before? set to false if not"
    type = bool
    default = true
}
variable "spokes-default-gateway" {
    description = "This is going to be the default-gateway for your spokes subnets"
    default = "172.16.1.4"
}