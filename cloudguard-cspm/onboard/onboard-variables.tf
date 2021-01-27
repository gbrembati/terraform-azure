variable "cspm-key-id" {
    description = "Insert your API Key ID"
    type = string
    default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
variable "cspm-key-secret" {
    description = "Insert your API Key Secret"
    type = string
    default = "xxxxxxxxxxxxxxxxxxxx"
}
variable "cspm-org-unit" {
    description = "Insert the name of your Organizational Unit"
    type = string
    default = "My Organization"
}

variable "azure-onboard" {
    description = "Do you need to onboard Azure accounts?"
    type = bool
    default = true
}
variable "azure-op-mode" {
    description = "Choose in which operating mode you want your Azure accounts to work"
    type = string
    default = "Read-Only"
}
locals { // locals for 'azure-op-mode' allowed values
    azure-op-mode_allowed_values = ["Managed", "Read"]
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

variable "aws-onboard" {
    description = "Do you need to onboard AWS accounts?"
    type = bool
    default = true
}
variable "aws-op-mode" {
    description = "Choose in which operating mode you want your AWS accounts to work"
    type = string
    default = "ReadOnly"
}
locals { // locals for 'azure-op-mode' allowed values
    aws-op-mode_allowed_values = ["ReadOnly", "FullManage", "Reset"]
    // will fail if [var.aws-op-mode] is invalid:
    validate_aws-op-mode = index(local.aws-op-mode_allowed_values, var.aws-op-mode)
}
variable "aws-accounts" {
    description = "Insert here your AWS Subscriptions details"
    sensitive = true
    default = {
        "0" = ["NAME","ARN","SECRET"]
#       "1" = ["NAME","ARN","SECRET"]
#       "2" = ["NAME","ARN","SECRET"]        
    }
}

variable "k8s-onboard" {
    description = "Do you need to onboard K8s Clusters?"
    type = bool
    default = true
}   
variable k8s-clusters {
    description = "Specify the name of the Clusters to onboard"   
    default = {
        "0" = "K8s-Cluster-1"
#       "1" = "K8s-Cluster-2"
#       "2" = "K8s-Cluster-3"
    }
}