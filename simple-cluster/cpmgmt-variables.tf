variable "mgmt-name" {
    description = "Choose the name of the management"
    default = "ckpmgmt"
}

variable "mgmt-sku" {
    description = "Choose the plan to deploy"
    default = "mgmt-byol"
}

variable "mgmt-version" {
    description = "Choose the version to deploy: either r8040 or r81"
    default = "r8040"
}

variable "mgmt-size" {
    description = "Choose the vm-size to deploy"
    default = "Standard_D3_v2"
}

variable "mgmt-admin-usr" {
    default = "cpadmin"
}

variable "my-pub-ip" {
    description = "Put your public-ip"
    default = "2.235.40.59/32"
}

variable "mgmt-sku-enabled" {
    description = "Have you ever deployed a ckp management before? set to false if not"
    type = bool
    default = true
}