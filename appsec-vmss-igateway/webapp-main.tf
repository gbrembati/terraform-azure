resource "azurerm_resource_group" "rg-app-juiceshop" {
  count    = length(var.num-container)
  name     = "rg-${var.container-name}-${lookup(var.num-container, count.index)[0]}"
  location = var.location
}

resource "azurerm_network_profile" "profile-app-juiceshop" {
  count               = length(var.num-container)
  name                = "net-profile-juiceshop-${lookup(var.num-container, count.index)[0]}"
  location            = azurerm_resource_group.rg-app-juiceshop[count.index].location
  resource_group_name = azurerm_resource_group.rg-app-juiceshop[count.index].name

  container_network_interface {
    name = "container-nic-${lookup(var.num-container, count.index)[0]}"

    ip_configuration {
      name      = "nic-ipconfig-${lookup(var.num-container, count.index)[0]}"
      subnet_id = azurerm_subnet.net-spoke-web[count.index].id
    }
  }
  depends_on = [azurerm_subnet.net-spoke-web]
}

resource "azurerm_container_group" "container-app-juiceshop" {
  count               = length(var.num-container)
  name                = "juiceshop${lookup(var.num-container, count.index)[0]}"
  location            = azurerm_resource_group.rg-app-juiceshop[count.index].location
  resource_group_name = azurerm_resource_group.rg-app-juiceshop[count.index].name
  os_type             = "Linux"
  ip_address_type     = "private"
  network_profile_id  = azurerm_network_profile.profile-app-juiceshop[count.index].id

  container {
    name   = "juiceshop${lookup(var.num-container, count.index)[0]}"
    image  = "${var.docker-image}:latest"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }
    ports {
      port     = 80
      protocol = "TCP"
    }    
  }

  tags = {
    environment = "${lookup(var.num-container, count.index)[0]}"
  }
  depends_on = [azurerm_virtual_network_peering.vnet-north-to-vnet-spoke,azurerm_virtual_network_peering.vnet-spoke-to-vnet-north]
} 