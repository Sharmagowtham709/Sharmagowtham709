resource "azurerm_public_ip" "bastion_host_linuxvm" {
    name                = "${local.resource_name_prefix}-bastion-host-publicip"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    allocation_method   = "Static"
    sku = "Standard"
}

resource "azurerm_network_interface" "bastion_host_linuxvm" {
    name                = "${local.resource_name_prefix}-bastion-host-linuxvm-nic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
      name                            = "bastion-host-ip-1"
      subnet_id                       = azurerm_subnet.bastion_subnet.id
      private_ip_address_allocation   = "Dynamic"
      public_ip_address_id            = azurerm_public_ip.bastion_host_linuxvm.id 
    }
}

resource "azurerm_linux_virtual_machine" "bastion_host_linuxvm" {
    name = "${local.resource_name_prefix}-bastion-linuxvm"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    size = "Standard_DS1_v2"
    admin_username = "azureuser"
    network_interface_ids = [ azurerm_network_interface.bastion_host_linuxvm_nic.id ]
    disable_password_authentication = false
    admin_ssh_key {
      username = "azureuser"
      password = "Welcome@123"
    }
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }
    source_image_reference {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "83-gen2"
      version   = "latest"
    }
}