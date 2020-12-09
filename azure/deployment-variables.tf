
variable "azure-client-id" {
    description = "Insert your application client-id"
    default = "xx-xx-xx-xx-xx"
} 
variable "azure-client-secret" {
    description = "Insert your application client-secret"
    default = "xx-xx-xx-xx-xx"
}
variable "azure-subscription" {
    description = "Insert your subscription-id"
    default = "xx-xx-xx-xx-xx"
}
variable "azure-tenant" {
    description = "Insert your active-directory-id"
    default = "xx-xx-xx-xx-xx"
}

variable "location" {
    description = "Choose where to deploy the environment"
    default = "France Central"
}

variable "my-pub-ip" {
    description = "Put your public-ip"
    default = "xx.xx.xx.xx/32"
}

variable "mgmt-dns-suffix" {
    description = "This is the public DNS suffix of your mgmt FQDN"
    default = "xxxxx"
}

variable "mgmt-admin-pwd" {
    description = "Choose your management admin password"
    default = "xxxxx"
}
