
variable "mgmt-name" {
    description = "Put the hostname of your management"
    type = string
    default = "ckpmgmt"
}
variable "mgmt-ip" {
    description = "Put the public IP address of your management"
    type = string
}
variable "api-username" {
    type = string
    sensitive = true
}
variable "api-password" {
    type = string
    sensitive = true
}
variable "provider-context" {
    description = "It can be used either web_api or gaia_api"
    default= "web_api"
}

variable "my-pub-ip" {
    description = "Put your public-ip"
    type = string
}

variable "new-policy-pkg" {
    description = "Define the name of your azure policy package"
    type = string
}

variable "azure-dc-name" {
    description = "Define the name of your azure datacenter-object"
    type = string
}

variable "mgmt-r81" {
    description = "Are you using Check Point Management with R81 or above?"
    type= bool
    default = false
}
variable "azure-ad-name" {
    description = "Define the name of your azure active-directory-object: used from R81"
    type = string
    default = "ad-azure"
}

variable "last-jhf" {
    description = "Provide the name of the JHF to be installed"
    type = string
    default = "Check_Point_R80_40_JUMBO_HF_Bundle_T89_sk165456_FULL.tgz"
}