variable "vmspoke-sku-enabled" {
    description = "If the plan is enabled marketplace to deploy"
    type = bool
    default = true
}

variable "vmspoke-name" {
    default = "vmspoke"
}

variable "vmspoke-publisher" {
    default = "bitnami"
}

variable "vmspoke-offer" {
    default = "nginxstack"
}

variable "vmspoke-sku" {
    default = "1-9"
}
