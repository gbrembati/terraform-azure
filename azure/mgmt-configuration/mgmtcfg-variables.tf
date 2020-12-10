
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

variable "mgmt-name" {
    description = "Put the hostname of your management"
    default = "ckpmgmt"
}
variable "mgmt-ip" {
    description = "Put the public IP address of your management"
    default= "x.x.x.x"
}
variable "api-username" {
    default= "xxxxx"
}
variable "api-password" {
    default= "xxxxx"
}
variable "provider-context" {
    description = "It can be used either web_api or gaia_api"
    default= "web_api"
}
variable "chosen-jhf" {
    description = "Specify the Jumbo Hotfix you want to be installed"
    default = "Check_Point_R80_40_JUMBO_HF_Bundle_T89_sk165456_FULL.tgz"
}

variable "my-pub-ip" {
    description = "Put your public-ip"
    default = "x.x.x.x"
}