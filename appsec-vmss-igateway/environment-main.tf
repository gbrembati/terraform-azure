terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.55.0"
    }
  }
}

# Configuration of Terraform with Azure environment variables
provider "azurerm" {
  features { }
  client_id           = var.azure-client-id
  client_secret       = var.azure-client-secret
  subscription_id     = var.azure-subscription
  tenant_id           = var.azure-tenant
}

# Creation of DNS Zone
resource "azurerm_resource_group" "rg-dns-myzone" {
  name                = "rg-dns-myzone"
  location            = var.location
}
resource "azurerm_dns_zone" "mydns-public-zone" {
  name                = var.mydns-zone
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
}

# Creation of the Northbound Hub
resource "azurerm_resource_group" "rg-vnet-north" {
  name                = "rg-v${var.net-north}"
  location            = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-north" {
  name                = "nsg-v${var.net-north}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on          = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_virtual_network" "vnet-north" {
  name                = "v${var.net-north}"
  address_space       = ["10.10.0.0/22"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on          = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_subnet" "net-north-frontend" {
  name                = "${azurerm_virtual_network.vnet-north.name}-frontend"
  address_prefixes    = ["10.10.0.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet-north.name
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on          = [azurerm_virtual_network.vnet-north]
}
resource "azurerm_subnet" "net-north-backend" {
  name                = "${azurerm_virtual_network.vnet-north.name}-backend"
  address_prefixes    = ["10.10.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet-north.name
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on          = [azurerm_virtual_network.vnet-north]
}

# Creation of the Spoke Num
resource "azurerm_resource_group" "rg-vnet-spoke" {
  count = length(var.num-spoke)
  name = "rg-v${var.net-spoke}-${count.index}"
  location = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-spoke" {
  count = length(var.num-spoke)
  name = "nsg-v${var.net-spoke}-${count.index}"
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  depends_on = [azurerm_resource_group.rg-vnet-spoke]
}
resource "azurerm_virtual_network" "vnet-spoke" {
  count = length(var.num-spoke)
  name = "v${var.net-spoke}-${count.index}"
  address_space = ["${lookup(var.num-spoke, count.index)[0]}/22"]
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  tags = {
    environment = "spoke"
  }
  depends_on = [azurerm_resource_group.rg-vnet-spoke]
}
resource "azurerm_subnet" "net-spoke-web" {
  count = length(var.num-spoke)
  name = "${var.net-spoke}-${count.index}-web"
  address_prefixes = ["${lookup(var.num-spoke, count.index)[0]}/24"]
  virtual_network_name = "v${var.net-spoke}-${count.index}"
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
  depends_on = [azurerm_virtual_network.vnet-spoke]
}
resource "azurerm_subnet" "net-spoke-db" {
  count = length(var.num-spoke)
  name = "${var.net-spoke}-${count.index}-db"
  address_prefixes = ["${lookup(var.num-spoke, count.index)[1]}/24"]
  virtual_network_name = "v${var.net-spoke}-${count.index}"
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  
  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
  depends_on = [azurerm_virtual_network.vnet-spoke]
}

# Routing Tables for Spoke
locals { // locals for 'next_hop_type' allowed values
  next_hop_type_allowed_values = ["VirtualNetworkGateway","VnetLocal","Internet","VirtualAppliance","None"]
}

resource "azurerm_route_table" "rt-vnet-spoke" {
  count = length(var.num-spoke)
  name = "rt-v${var.net-spoke}-${count.index}"
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  depends_on = [azurerm_resource_group.rg-vnet-spoke]

  route {
    name = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[2]
  }
  route {
    name = "route-to-vnet-addrspace"
    address_prefix = azurerm_virtual_network.vnet-spoke[count.index].address_space[0]
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-web" {
  count = length(var.num-spoke)
  subnet_id = azurerm_subnet.net-spoke-web[count.index].id
  route_table_id = azurerm_route_table.rt-vnet-spoke[count.index].id
  depends_on = [azurerm_subnet.net-spoke-web,azurerm_route_table.rt-vnet-spoke]
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-db" {
  count = length(var.num-spoke)
  subnet_id = azurerm_subnet.net-spoke-db[count.index].id
  route_table_id = azurerm_route_table.rt-vnet-spoke[count.index].id
  depends_on = [azurerm_subnet.net-spoke-db,azurerm_route_table.rt-vnet-spoke]
}

# Peering from/to spoke to north
resource "azurerm_virtual_network_peering" "vnet-spoke-to-vnet-north" {
  count = length(var.num-spoke)
  name = "v${var.net-spoke}-${count.index}-to-v${var.net-north}"
  resource_group_name = "rg-v${var.net-spoke}-${count.index}"
  virtual_network_name = "v${var.net-spoke}-${count.index}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-north.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-web,azurerm_subnet.net-spoke-db,
                azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-north-to-vnet-spoke" {
  count = length(var.num-spoke)
  name = "v${var.net-north}-to-v${var.net-spoke}-${count.index}"
  resource_group_name = "rg-v${var.net-north}"
  virtual_network_name = "v${var.net-north}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke[count.index].id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-web,azurerm_subnet.net-spoke-db,
                azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}