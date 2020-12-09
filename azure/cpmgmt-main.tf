# Accept the agreement for the mgmt-byol for R80.40
resource "azurerm_marketplace_agreement" "cp-agreement" {
  count = var.mgmt-sku-enabled ? 0 : 1
  publisher = "checkpoint"
  offer = "check-point-cg-${var.mgmt-version}"
  plan = var.mgmt-sku
}

# Create management resource group
resource "azurerm_resource_group" "rg-ckpmgmt" {
  name = "rg-${var.mgmt-name}"
  location = var.location
}

# Create Public IP
resource "azurerm_public_ip" "pub-ckpmgmt" {
    name = "pub-${var.mgmt-name}"
    location = var.location
    resource_group_name = "rg-${var.mgmt-name}"
    allocation_method = "Dynamic"
    domain_name_label = "pub-${var.mgmt-name}-${var.mgmt-dns-suffix}"
    depends_on = [azurerm_resource_group.rg-ckpmgmt]
}

# Create NIC
resource "azurerm_network_interface" "nic-ckpmgmt" {
    name                = "${var.mgmt-name}-eth0"
    location            = var.location
    resource_group_name = "rg-${var.mgmt-name}"
    enable_ip_forwarding = "false"
    
	ip_configuration {
        name = "${var.mgmt-name}-eth0-config"
        subnet_id = azurerm_subnet.net-secmgmt.id
        private_ip_address_allocation = "Static"
		private_ip_address = "172.16.8.4"
        primary = true
		public_ip_address_id = azurerm_public_ip.pub-ckpmgmt.id
    }
    depends_on = [azurerm_public_ip.pub-ckpmgmt,azurerm_subnet.net-secmgmt]
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "rg-${var.mgmt-name}"
    }
    byte_length = 8
    depends_on = [azurerm_resource_group.rg-ckpmgmt]
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "ckp-storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "rg-${var.mgmt-name}"
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
    depends_on = [random_id.randomId,azurerm_resource_group.rg-ckpmgmt]
}

# Create virtual machine
resource "azurerm_virtual_machine" "ckpmgmt" {
    name                  = var.mgmt-name
    location              = var.location
    resource_group_name   = "rg-${var.mgmt-name}"
    network_interface_ids = [azurerm_network_interface.nic-ckpmgmt.id]
    primary_network_interface_id = azurerm_network_interface.nic-ckpmgmt.id
    vm_size               = var.mgmt-size
    
    # parameters = { "installationType" = "management" }

    storage_os_disk {
        name              = "disk-${var.mgmt-name}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    storage_image_reference {
        publisher = "checkpoint"
        offer     = "check-point-cg-${var.mgmt-version}"
        sku       = var.mgmt-sku
        version   = "latest"
    }
    plan {
        name = var.mgmt-sku
        publisher = "checkpoint"
        product = "check-point-cg-${var.mgmt-version}"
    }
    os_profile {
        computer_name  = var.mgmt-name
		admin_username = var.mgmt-admin-usr
        admin_password = var.mgmt-admin-pwd
        custom_data = file("customsettings.sh")
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.ckp-storageaccount.primary_blob_endpoint
    }
    depends_on = [azurerm_marketplace_agreement.cp-agreement,azurerm_resource_group.rg-ckpmgmt,
                azurerm_network_interface.nic-ckpmgmt,azurerm_storage_account.ckp-storageaccount]
}

output "mgmt-output-ip" {
  value = azurerm_public_ip.pub-ckpmgmt.ip_address
  depends_on = [azurerm_public_ip.pub-ckpmgmt]
}  
output "mgmt-output-fqdn-prexif" {
  value = azurerm_public_ip.pub-ckpmgmt.domain_name_label
  depends_on = [azurerm_public_ip.pub-ckpmgmt]
}