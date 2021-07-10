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
    default = "France Central"
}

