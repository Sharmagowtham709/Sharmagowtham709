
locals{
    VMProperties ={
        name = "VMLinux"
        size = "Standard_DS1_v2"
        
    }
}

resource "tls_private_key" "privateKey" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "azurerm_public_ip" "publicIP-01" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    name = var.publicIP_name
    allocation_method = "Static"
}

resource "azurerm_network_interface" "nic-01" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    name = "${var.NetworkInterface}-${random_string.myrandom.id}"
    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.websubnet.id 
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicIP-01.id
    }
    tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "vm-01" {
    
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    name = "${local.VMProperties.name}-${random_string.myrandom.id}"
    size = local.VMProperties.size
    network_interface_ids = [azurerm_network_interface.nic-01.id]
    admin_username = "adminuser"
    admin_ssh_key {
        username = "adminuser"
        public_key = tls_private_key.privateKey.public_key_openssh
    }
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    source_image_reference {
        publisher = "RedHat"
        offer = "RHEL"
        sku = "83-gen2"
        version = "latest"
    }
    custom_data = filebase64("${path.module}/appinstallation.sh")
    tags = local.common_tags
}