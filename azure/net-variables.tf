
variable "net-north" {
    description = "resources in the north"
    default = "net-north"
}

variable "net-south" {
    description = "resources in the south"
    default = "net-south"
}

variable "net-secmgmt" {
    description = "resources in the management"
    default = "net-mgmt"
}

variable "net-spoke" {
    description = "resources in the spoke"
    default = "net-spoke"
}

variable "num-spoke" {
  default = {
    "0" = ["10.0.0.0","10.0.1.0"]
    "1" = ["10.0.4.0","10.0.5.0"]
#    "2" = ["10.0.8.0","10.0.9.0"] # un-comment to deploy 3 spokes
  }
}
