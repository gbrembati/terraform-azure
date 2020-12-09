#VM-Spoke resource group
resource "azurerm_resource_group" "rg-vmspoke" {
    count = length(var.num-spoke)
    name = "rg-v${var.vmspoke-name}-${count.index}"
    location = var.location
}

#VM-Spoke Create Public IP
resource "azurerm_public_ip" "pub-vmspoke" {
    count = length(var.num-spoke)
    name = "pub-${var.vmspoke-name}-${count.index}"
    location = var.location
    resource_group_name = "rg-v${var.vmspoke-name}-${count.index}"
    allocation_method = "Dynamic"
    domain_name_label = "pub-${var.vmspoke-name}-${count.index}-${var.mgmt-dns-suffix}"
    depends_on = [azurerm_resource_group.rg-vmspoke]
}

#VM-Spoke Network interface
resource "azurerm_network_interface" "nic-vmspoke" {
    count = length(var.num-spoke)
    name = "${var.vmspoke-name}-${count.index}-eth0"
    location = var.location
    resource_group_name = "rg-v${var.vmspoke-name}-${count.index}"
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


#VM-Spoke Virtual Machine
resource "azurerm_virtual_machine" "virtual_machine" {
    count = length(var.num-spoke)
    name = "${var.vmspoke-name}-${count.index}"
    location = var.location
    resource_group_name = "rg-v${var.vmspoke-name}-${count.index}"
    network_interface_ids = [azurerm_network_interface.nic-vmspoke[count.index].id]
    vm_size = "Standard_A1_v2"

    plan {
        publisher = var.vmspoke-publisher
        product = var.vmspoke-offer
        name = var.vmspoke-sku
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
}