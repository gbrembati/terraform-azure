# Accept the agreement for the mgmt-byol for vmspoke image
resource "azurerm_marketplace_agreement" "vmspoke-agreement" {
  count = var.vmspoke-sku-enabled ? 0 : 1
  publisher = var.vmspoke-publisher
  offer = var.vmspoke-offer
  plan = var.vmspoke-sku
}

# VM-Spoke resource group
resource "azurerm_resource_group" "rg-vmspoke" {
    count = var.deploy-vmspoke ? length(var.num-spoke) : 0
    name = "rg-${var.vmspoke-name}-${count.index}"
    location = var.location
}

# VM-Spoke Create Public IP
resource "azurerm_public_ip" "pub-vmspoke" {
    count = var.deploy-vmspoke ? length(var.num-spoke) : 0
    name = "pub-${var.vmspoke-name}-${count.index}"
    location = var.location
    resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
    allocation_method = "Dynamic"
    domain_name_label = "pub-${var.vmspoke-name}-${count.index}-${var.mgmt-dns-suffix}"
    depends_on = [azurerm_resource_group.rg-vmspoke]
}

# VM-Spoke Network interface
resource "azurerm_network_interface" "nic-vmspoke" {
    count = var.deploy-vmspoke ? length(var.num-spoke) : 0
    name = "${var.vmspoke-name}-${count.index}-eth0"
    location = var.location
    resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
    enable_ip_forwarding = "false"
    
	ip_configuration {
        name = "${var.vmspoke-name}-${count.index}-eth0-config"
        subnet_id = azurerm_subnet.net-spoke-web[count.index].id
        private_ip_address_allocation = "Dynamic"
        primary = true
		public_ip_address_id = azurerm_public_ip.pub-vmspoke[count.index].id
    }
    depends_on = [azurerm_public_ip.pub-vmspoke,azurerm_subnet.net-spoke-web]
}

# Create NSG for the vmspoke
resource "azurerm_network_security_group" "nsg-vmspoke" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0
  name = "nsg-${var.vmspoke-name}-${count.index}"
  location = var.location
  resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
  depends_on = [azurerm_resource_group.rg-vmspoke]
}

# Create the NSG rules for the vmspoke
resource "azurerm_network_security_rule" "nsg-vmspoke-rl-ssh" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0   
  priority = 100
  name = "ssh-access"

  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix  = var.my-pub-ip
  destination_address_prefix = "*"
  resource_group_name  = "rg-${var.vmspoke-name}-${count.index}"
  network_security_group_name = "nsg-${var.vmspoke-name}-${count.index}"
  depends_on = [azurerm_network_security_group.nsg-vmspoke]
}
resource "azurerm_network_security_rule" "nsg-vmspoke-rl-http-s" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0   
  priority = 110
  name = "http-s-access"

  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_ranges = ["80","443"]
  source_address_prefix  = "*"
  destination_address_prefix = "*"
  resource_group_name  = "rg-${var.vmspoke-name}-${count.index}"
  network_security_group_name = "nsg-${var.vmspoke-name}-${count.index}"
  depends_on = [azurerm_network_security_group.nsg-vmspoke]
}

resource "azurerm_network_interface_security_group_association" "nsg-assoc-nic-vmspoke" {
  count = var.deploy-vmspoke ? length(var.num-spoke) : 0
  network_interface_id      = azurerm_network_interface.nic-vmspoke[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-vmspoke[count.index].id
  depends_on = [azurerm_network_interface.nic-vmspoke,azurerm_network_security_group.nsg-vmspoke]
}

# VM-Spoke Virtual Machine
resource "azurerm_virtual_machine" "vm-spoke" {
    count = var.deploy-vmspoke ? length(var.num-spoke) : 0
    name = "${var.vmspoke-name}-${count.index}"
    location = var.location
    resource_group_name = "rg-${var.vmspoke-name}-${count.index}"
    network_interface_ids = [azurerm_network_interface.nic-vmspoke[count.index].id]
    vm_size = "Standard_A1_v2"

    plan {
        publisher = var.vmspoke-publisher
        product = var.vmspoke-offer
        name = var.vmspoke-sku
    }
    storage_image_reference {
        publisher = var.vmspoke-publisher
        offer     = var.vmspoke-offer
        sku       = var.vmspoke-sku
        version   = "latest"
    }
    storage_os_disk {
        name              = "disk-${var.vmspoke-name}-${count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "${var.vmspoke-name}-${count.index}"
		admin_username = var.mgmt-admin-usr
        admin_password = var.mgmt-admin-pwd
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
    depends_on = [azurerm_marketplace_agreement.vmspoke-agreement,azurerm_resource_group.rg-vmspoke,
                azurerm_network_interface.nic-vmspoke]
}

output "vmspoke-output-fqdn" {
  value = azurerm_public_ip.pub-vmspoke[*].fqdn
  depends_on = [azurerm_public_ip.pub-vmspoke]
}