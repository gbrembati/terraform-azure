variable "azure-client-id" {
    description = "Insert your application client-id"
    type = string
    sensitive = true    
} 
variable "azure-client-secret" {
    description = "Insert your application client-secret"
    type = string
    sensitive = true
}
variable "azure-subscription" {
    description = "Insert your subscription-id"
    type = string
    sensitive = true
}
variable "azure-tenant" {
    description = "Insert your active-directory-id"
    type = string
    sensitive = true
}
variable "location" {
    description = "Choose where to deploy the environment"
    type = string
}
variable "mydns-zone" {
    description = "Specify your dns zone"
    type = string
}
variable "net-north" {
    description = "resources in the north"
    type = string
}
variable "net-spoke" {
    description = "resources in the spoke"
    type = string
}
variable "num-spoke" {
  default = {
    "0" = ["10.0.0.0","10.0.1.0"]
    "1" = ["10.0.4.0","10.0.5.0"]
  }
}