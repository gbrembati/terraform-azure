variable "cspm-key-id" {
    description = "Insert your API Key ID"
    type = string
    sensitive = true
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
variable "cspm-key-secret" {
    description = "Insert your API Key Secret"
    type = string
    sensitive = true
    default = "xxxxxxxxxxxxxxxxxxxx"
}
variable "cspm-org-unit" {
    description = "Insert the name of your Organizational Unit"
    type = string
    default = "My Organization"
}

variable "azure-op-mode" {
    description = "Choose in which operating mode you want your Azure accounts to work"
    type = string
    default = "Read-Only"
}
locals { // locals for 'azure-op-mode' allowed values
    azure-op-mode_allowed_values = ["Managed", "Read-Only"]
    // will fail if [var.azure-op-mode] is invalid:
    validate_azure-op-mode = index(local.azure-op-mode_allowed_values, var.azure-op-mode)
}

variable "azure-accounts" {
    description = "Insert here your Azure Subscriptions details"
    sensitive = true
    default = {
        "0" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
#       "1" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
#       "2" = ["NAME","SUBSCRIPTION ID","TENANT ID","CLIENT ID","CLIENT PASSWORD"]
    }
}