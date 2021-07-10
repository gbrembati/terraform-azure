variable "num-container" {
  default = {
    "0" = ["prod"]
    "1" = ["staging"]
  }
}
variable "container-name" {
  default = "juiceshop"
}
variable "docker-image" {
  default = "bkimminich/juice-shop"
}