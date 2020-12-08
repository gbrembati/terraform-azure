# Configuration of Terraform with Azure environment variables
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
resource "azurerm_network_security_group" "sg-vnet-north" {
  name = "sg-v${var.net-north}"
  location = var.location
  resource_group_name = "rg-v${var.net-north}"
  depends_on = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_virtual_network" "vnet-north" {
  name = "v${var.net-north}"
  address_space = ["172.16.0.0/22"]
  location = var.location
  resource_group_name = "rg-v${var.net-north}"
  tags = {
    environment = "north"
  }
  depends_on = [azurerm_resource_group.rg-vnet-north]
}
resource "azurerm_subnet" "net-north-frontend" {
  name = "${var.net-north}-frontend"
  address_prefixes = ["172.16.0.0/24"]
  virtual_network_name = "v${var.net-north}"
  resource_group_name = "rg-v${var.net-north}"
  depends_on = [azurerm_virtual_network.vnet-north]
}
resource "azurerm_subnet" "net-north-backend" {
  name = "${var.net-north}-backend"
  address_prefixes = ["172.16.1.0/24"]
  virtual_network_name = "v${var.net-north}"
  resource_group_name = "rg-v${var.net-north}"
  depends_on = [azurerm_virtual_network.vnet-north]
}

# Creation of the Southbound Hub
resource "azurerm_resource_group" "rg-vnet-south" {
  name = "rg-v${var.net-south}"
  location = var.location
}
resource "azurerm_network_security_group" "sg-vnet-south" {
  name = "sg-v${var.net-south}"
  location = var.location
  resource_group_name = "rg-v${var.net-south}"
  depends_on = [azurerm_resource_group.rg-vnet-south]
}
resource "azurerm_virtual_network" "vnet-south" {
  name = "v${var.net-south}"
  address_space = ["172.16.4.0/22"]
  location = var.location
  resource_group_name = "rg-v${var.net-south}"
  tags = {
    environment = "south"
  }
  depends_on = [azurerm_resource_group.rg-vnet-south]
}
resource "azurerm_subnet" "net-south-frontend" {
  name = "${var.net-south}-frontend"
  address_prefixes = ["172.16.4.0/24"]
  virtual_network_name = "v${var.net-south}"
  resource_group_name = "rg-v${var.net-south}"
  depends_on = [azurerm_virtual_network.vnet-south]
}
resource "azurerm_subnet" "net-south-backend" {
  name = "${var.net-south}-backend"
  address_prefixes = ["172.16.5.0/24"]
  virtual_network_name = "v${var.net-south}"
  resource_group_name = "rg-v${var.net-south}"
  depends_on = [azurerm_virtual_network.vnet-south]
}

# Creation of the Management Hub
resource "azurerm_resource_group" "rg-vnet-secmgmt" {
  name = "rg-v${var.net-secmgmt}"
  location = var.location
}
resource "azurerm_network_security_group" "sg-vnet-secmgmt" {
  name = "sg-v${var.net-secmgmt}"
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
  resource_group_name = "rg-v${var.net-north}"
  virtual_network_name = "v${var.net-north}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-secmgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}

# Peering from/to Management Hub to Southbound Hub
resource "azurerm_virtual_network_peering" "vnet-secmgmt-to-vnet-south" {
  name = "v${var.net-secmgmt}-to-v${var.net-south}"
  resource_group_name = "rg-v${var.net-secmgmt}"
  virtual_network_name = "v${var.net-secmgmt}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-south.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-south-to-vnet-secmgmt" {
  name = "v${var.net-south}-to-v${var.net-secmgmt}"
  resource_group_name = "rg-v${var.net-south}"
  virtual_network_name = "v${var.net-south}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-secmgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-secmgmt,azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}

# Creation of the Spoke Num1
resource "azurerm_resource_group" "rg-vnet-spoke-1" {
  name = "rg-v${var.net-spoke}-1"
  location = var.location
}
resource "azurerm_network_security_group" "sg-vnet-spoke-1" {
  name = "sg-v${var.net-spoke}-1"
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-1"
  depends_on = [azurerm_resource_group.rg-vnet-spoke-1]
}
resource "azurerm_virtual_network" "vnet-spoke-1" {
  name = "v${var.net-spoke}-1"
  address_space = ["10.0.0.0/22"]
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-1"
  tags = {
    environment = "spoke-1"
  }
  depends_on = [azurerm_resource_group.rg-vnet-spoke-1]
}
resource "azurerm_subnet" "net-spoke-1-web" {
  name = "${var.net-spoke}-1-web"
  address_prefixes = ["10.0.0.0/24"]
  virtual_network_name = "v${var.net-spoke}-1"
  resource_group_name = "rg-v${var.net-spoke}-1"
  depends_on = [azurerm_virtual_network.vnet-spoke-1]
}
resource "azurerm_subnet" "net-spoke-1-db" {
  name = "${var.net-spoke}-1-db"
  address_prefixes = ["10.0.1.0/24"]
  virtual_network_name = "v${var.net-spoke}-1"
  resource_group_name = "rg-v${var.net-spoke}-1"
  depends_on = [azurerm_virtual_network.vnet-spoke-1]
}

# Peering from/to spoke to north
resource "azurerm_virtual_network_peering" "vnet-spoke-1-to-vnet-north" {
  name = "v${var.net-spoke}-1-to-v${var.net-north}"
  resource_group_name = "rg-v${var.net-spoke}-1"
  virtual_network_name = "v${var.net-spoke}-1"
  remote_virtual_network_id = azurerm_virtual_network.vnet-north.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-1-web,azurerm_subnet.net-spoke-1-db,
                azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-north-to-vnet-spoke-1" {
  name = "v${var.net-north}-to-v${var.net-spoke}-1"
  resource_group_name = "rg-v${var.net-north}"
  virtual_network_name = "v${var.net-north}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke-1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-1-web,azurerm_subnet.net-spoke-1-db,
                azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}

# Peering from/to spoke to south
resource "azurerm_virtual_network_peering" "vnet-spoke-1-to-vnet-south" {
  name = "v${var.net-spoke}-1-to-v${var.net-south}"
  resource_group_name = "rg-v${var.net-spoke}-1"
  virtual_network_name = "v${var.net-spoke}-1"
  remote_virtual_network_id = azurerm_virtual_network.vnet-south.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-1-web,azurerm_subnet.net-spoke-1-db,
                azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-south-to-vnet-spoke-1" {
  name = "v${var.net-south}-to-v${var.net-spoke}-1"
  resource_group_name = "rg-v${var.net-south}"
  virtual_network_name = "v${var.net-south}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke-1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-1-web,azurerm_subnet.net-spoke-1-db,
                azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}

# Routing Tables for Spoke
locals { // locals for 'next_hop_type' allowed values
  next_hop_type_allowed_values = ["VirtualNetworkGateway","VnetLocal","Internet","VirtualAppliance","None"]
}

resource "azurerm_route_table" "rt-vnet-spoke-1" {
  name = "rt-v${var.net-spoke}-1"
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-1"
  depends_on = [azurerm_resource_group.rg-vnet-spoke-1]

  route {
    name = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[3]
    next_hop_in_ip_address = "172.16.1.4"
  }
  route {
    name = "route-to-my-pub-ip"
    address_prefix = var.my-pub-ip
    next_hop_type = local.next_hop_type_allowed_values[2]
  }
  route {
    name = "route-to-vnet-addrspace"
    address_prefix = azurerm_virtual_network.vnet-spoke-1.address_space[0]
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-1-web" {
  subnet_id = azurerm_subnet.net-spoke-1-web.id
  route_table_id = azurerm_route_table.rt-vnet-spoke-1.id
  depends_on = [azurerm_subnet.net-spoke-1-web,azurerm_route_table.rt-vnet-spoke-1]
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-1-db" {
  subnet_id = azurerm_subnet.net-spoke-1-db.id
  route_table_id = azurerm_route_table.rt-vnet-spoke-1.id
  depends_on = [azurerm_subnet.net-spoke-1-db,azurerm_route_table.rt-vnet-spoke-1]
}

# Spoke Num2
resource "azurerm_resource_group" "rg-vnet-spoke-2" {
  name = "rg-v${var.net-spoke}-2"
  location = var.location
}
resource "azurerm_network_security_group" "sg-vnet-spoke-2" {
  name = "sg-v${var.net-spoke}-2"
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-2"
  depends_on = [azurerm_resource_group.rg-vnet-spoke-2]
}
resource "azurerm_virtual_network" "vnet-spoke-2" {
  name = "v${var.net-spoke}-2"
  address_space = ["10.0.4.0/22"]
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-2"
  tags = {
    environment = "spoke-2"
  }
  depends_on = [azurerm_resource_group.rg-vnet-spoke-2]
}
resource "azurerm_subnet" "net-spoke-2-web" {
  name = "${var.net-spoke}-2-web"
  address_prefixes = ["10.0.4.0/24"]
  virtual_network_name = "v${var.net-spoke}-2"
  resource_group_name = "rg-v${var.net-spoke}-2"
  depends_on = [azurerm_virtual_network.vnet-spoke-2]
}
resource "azurerm_subnet" "net-spoke-2-db" {
  name = "${var.net-spoke}-2-db"
  address_prefixes = ["10.0.5.0/24"]
  virtual_network_name = "v${var.net-spoke}-2"
  resource_group_name = "rg-v${var.net-spoke}-2"
  depends_on = [azurerm_virtual_network.vnet-spoke-2]
}

# Peering from/to spoke to north
resource "azurerm_virtual_network_peering" "vnet-spoke-2-to-vnet-north" {
  name = "v${var.net-spoke}-2-to-v${var.net-north}"
  resource_group_name = "rg-v${var.net-spoke}-2"
  virtual_network_name = "v${var.net-spoke}-2"
  remote_virtual_network_id = azurerm_virtual_network.vnet-north.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-2-web,azurerm_subnet.net-spoke-2-db,
                azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-north-to-vnet-spoke-2" {
  name = "v${var.net-north}-to-v${var.net-spoke}-2"
  resource_group_name = "rg-v${var.net-north}"
  virtual_network_name = "v${var.net-north}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke-2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-2-web,azurerm_subnet.net-spoke-2-db,
                azurerm_subnet.net-north-backend,azurerm_subnet.net-north-frontend]
}

# Peering from/to spoke to south
resource "azurerm_virtual_network_peering" "vnet-spoke-2-to-vnet-south" {
  name = "v${var.net-spoke}-2-to-v${var.net-south}"
  resource_group_name = "rg-v${var.net-spoke}-2"
  virtual_network_name = "v${var.net-spoke}-2"
  remote_virtual_network_id = azurerm_virtual_network.vnet-south.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-2-web,azurerm_subnet.net-spoke-2-db,
                azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}
resource "azurerm_virtual_network_peering" "vnet-south-to-vnet-spoke-2" {
  name = "v${var.net-south}-to-v${var.net-spoke}-2"
  resource_group_name = "rg-v${var.net-south}"
  virtual_network_name = "v${var.net-south}"
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke-2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit = false
  depends_on = [azurerm_subnet.net-spoke-2-web,azurerm_subnet.net-spoke-2-db,
                azurerm_subnet.net-south-backend,azurerm_subnet.net-south-frontend]
}

# Routing Tables for Spoke

resource "azurerm_route_table" "rt-vnet-spoke-2" {
  name = "rt-v${var.net-spoke}-2"
  location = var.location
  resource_group_name = "rg-v${var.net-spoke}-2"
  depends_on = [azurerm_resource_group.rg-vnet-spoke-2]

  route {
    name = "route-to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = local.next_hop_type_allowed_values[3]
    next_hop_in_ip_address = "172.16.1.4"
  }
  route {
    name = "route-to-my-pub-ip"
    address_prefix = var.my-pub-ip
    next_hop_type = local.next_hop_type_allowed_values[2]
  }
  route {
    name = "route-to-vnet-addrspace"
    address_prefix = azurerm_virtual_network.vnet-spoke-2.address_space[0]
    next_hop_type = local.next_hop_type_allowed_values[1]
  }
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-2-web" {
  subnet_id = azurerm_subnet.net-spoke-2-web.id
  route_table_id = azurerm_route_table.rt-vnet-spoke-2.id
  depends_on = [azurerm_subnet.net-spoke-2-web,azurerm_route_table.rt-vnet-spoke-2]
}
resource "azurerm_subnet_route_table_association" "rt-assoc-net-spoke-2-db" {
  subnet_id = azurerm_subnet.net-spoke-2-db.id
  route_table_id = azurerm_route_table.rt-vnet-spoke-2.id
  depends_on = [azurerm_subnet.net-spoke-2-db,azurerm_route_table.rt-vnet-spoke-2]
}