variable cluster-name {
    description = "Choose the machine name"
    default = "ckp-cluster"
}
variable cluster-size {
    description = "Choose the machine size"
    default = "n1-standard-4"
}
variable cluster-sic {
    description = "Choose the machine size"
    default = "xxxxxxxxxx"
    sensitive = true
}