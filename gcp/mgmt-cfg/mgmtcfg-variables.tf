variable mgmt-name {
    description = "Choose the machine name"
    default = "ckp-mgmt"

}
variable api-username {
    default= "apiadmin"
}
variable api-password {
    default= "xxxxxxxxxx"
    sensitive = true
}
variable provider-context {
    description = "It can be used either web_api or gaia_api"
    default= "web_api"
}

variable my-pubip {
    description = "Put your public-ip"
    default = "xx.xx.xx.xx"
}

variable "new-policy-pkg" {
    description = "Define the name of your azure policy package"
    default = "pkg-gcp"
}

variable "gcp-dc-name" {
    description = "Define the name of your azure datacenter-object"
    default = "dc-gcp"
}

variable "last-jhf" {
    description = "Provide the name of the JHF to be installed"
    default = "Check_Point_R80_40_JUMBO_HF_Bundle_T91_sk165456_FULL.tgz"
}

variable "mgmt-ip" {
    description = "Put the public IP address of your management"
    default= "xx.xx.xx.xx"
}
variable cluster-sic {
    description = "Choose the cluster SIC"
    default = "xxxxxxxxxx"
    sensitive = true
}

variable cluster-vip {
    description = "Specify the Public IP of the Cluster"
    default = "xx.xx.xx.xx"
}
variable ip-member-a {
    description = "Specify the Public IP of the Member A"
    default = "xx.xx.xx.xx"
}
variable ip-member-b {
    description = "Specify the Public IP of the Member B"
    default = "xx.xx.xx.xx"
}