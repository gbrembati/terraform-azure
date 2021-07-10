# Configuration of Terraform with Azure environment variables
terraform {
  required_version = ">= 0.14.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.17.0"
    }
    random = {
      version = "~> 2.2.1"
    }
  }
}

provider "azurerm" {
  features { }
  client_id = var.azure-client-id
  client_secret = var.azure-client-secret
  subscription_id = var.azure-subscription
  tenant_id = var.azure-tenant
}

# Creation of the Northbound Hub
resource "azurerm_resource_group" "rg-vnet-north" {
  name = "rg-v${var.net-north}"
  location = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-north" {
  name = "nsg-v${var.net-north}"
  location = azurerm_resource_group.rg-vnet-north.location
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_virtual_network" "vnet-north" {
  name = "v${var.net-north}"
  address_space = ["172.16.0.0/22"]
  location = azurerm_resource_group.rg-vnet-north.location
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  tags = {
    environment = "north"
  }
  depends_on = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_subnet" "net-north-frontend" {
  name = "${var.net-north}-frontend"
  address_prefixes = ["172.16.0.0/24"]
  virtual_network_name = "v${var.net-north}"
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on = [azurerm_virtual_network.vnet-north]
}
resource "azurerm_subnet" "net-north-backend" {
  name = "${var.net-north}-backend"
  address_prefixes = ["172.16.1.0/24"]
  virtual_network_name = "v${var.net-north}"
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on = [azurerm_virtual_network.vnet-north]
}
resource "azurerm_subnet" "net-web" {
  name = "${var.net-north}-web"
  address_prefixes = ["172.16.2.0/24"]
  virtual_network_name = "v${var.net-north}"
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  depends_on = [azurerm_virtual_network.vnet-north]
}

locals { // locals for 'next_hop_type' allowed values
  next_hop_type_allowed_values = ["VirtualNetworkGateway","VnetLocal","Internet","VirtualAppliance","None"]
}

resource "azurerm_route_table" "rt-net-web" {
  name = "rt-${azurerm_subnet.net-web.name}"
  location = azurerm_resource_group.rg-vnet-north.location
  resource_group_name = azurerm_resource_group.rg-vnet-north.name

  route {
    name = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[3]
    next_hop_in_ip_address = "172.16.1.5"
  }
  route {
    name = "route-to-vnet-addrspace"
    address_prefix = azurerm_virtual_network.vnet-north.address_space[0]
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
}

resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-web" {
  subnet_id = azurerm_subnet.net-web.id
  route_table_id = azurerm_route_table.rt-net-web.id
  depends_on = [azurerm_subnet.net-web,azurerm_route_table.rt-net-web]
}

# Creation of the Management Hub
resource "azurerm_resource_group" "rg-vnet-secmgmt" {
  name = "rg-v${var.net-secmgmt}"
  location = var.location
}
resource "azurerm_network_security_group" "nsg-vnet-secmgmt" {
  name = "nsg-v${var.net-secmgmt}"
  location = var.location
  resource_group_name = "rg-v${var.net-secmgmt}"
  depends_on = [azurerm_resource_group.rg-vnet-secmgmt]
}
resource "azurerm_virtual_network" "vnet-secmgmt" {
  name = "v${var.net-secmgmt}"
  address_space = ["172.16.8.0/22"]
  location = var.location
  resource_group_name = "rg-v${var.net-secmgmt}"
  tags = {
    environment = "management"
  }
  depends_on = [azurerm_resource_group.rg-vnet-secmgmt]
}
resource "azurerm_subnet" "net-secmgmt" {
  name = var.net-secmgmt
  address_prefixes = ["172.16.8.0/24"]
  virtual_network_name = "v${var.net-secmgmt}"
  resource_group_name = "rg-v${var.net-secmgmt}"
  depends_on = [azurerm_virtual_network.vnet-secmgmt]
}

# Peering from/to Management Hub to Nouthbound Hub
resource "azurerm_virtual_network_peering" "vnet-secmgmt-to-vnet-north" {
  name = "v${var.net-secmgmt}-to-v${var.net-north}"
  resource_group_name = "rg-v${var.net-secmgmt}"
  virtual_network_name = "v${var.net-secmgmt}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-north.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-north-to-vnet-secmgmt" {
  name = "v${var.net-north}-to-v${var.net-secmgmt}"
  resource_group_name = azurerm_resource_group.rg-vnet-north.name
  virtual_network_name = "v${var.net-north}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-secmgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}