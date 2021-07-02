variable "azure-client-id" {
    description = "Insert your application client-id"
} 
variable "azure-client-secret" {
    description = "Insert your application client-secret"
}
variable "azure-subscription" {
    description = "Insert your subscription-id"
}
variable "azure-tenant" {
    description = "Insert your active-directory-id"
}

variable "location" {
    description = "Choose where to deploy the environment"
    default = "France Central"
}

