variable gcp-region {
    description = "Where do you want to create it?"
    type = string
    default = "europe-west2"
}
variable gcp-project-id {
    description = "Where do you want to create it?"
    type = string
    default = "cp-lab-probject"
}

variable vpc-mtu {
    description = "Choose the MTU size of the VPCs"
    type = string
    default = "1460"
}
locals { // locals for 'vpc-mtu' allowed values
    vpc-mtu_allowed_values = ["1460", "1500"]
    // will fail if [var.vpc-mtu] is invalid:
    validate_vpc-mtu = index(local.vpc-mtu_allowed_values, var.vpc-mtu)
}

variable vpc-north {
    description = "Name of the north resources"
    type = string
    default = "north"
}
variable vpc-south {
    description = "Name of the south resources"
    type = string
    default = "south"
}
variable vpc-mgmt {
    description = "Name of the north resources"
    type = string
    default = "mgmt"
}

variable "vpc-spoke" {
    description = "Describe each spoke name and CIDR"
    default = {
    "0" = ["dev","10.1.0.0/22"]
    "1" = ["prod","10.2.0.0/22"]
  }
}

variable "my-dns-zone" {
    description = "Describe the 2nd level domain of your zone"
    default = "xxxxxxxxxx"
}