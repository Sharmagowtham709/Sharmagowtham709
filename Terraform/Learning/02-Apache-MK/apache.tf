terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.95.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG" {
  name     = "Mukesh-RG"
  location = "eastus"
}

resource "azurerm_virtual_network" "VN" {
  name                = "TF-VN"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

}

resource "azurerm_subnet" "Subnet" {
  name                 = "Tf-Subnet"
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VN.name
}

resource "azurerm_public_ip" "publicip" {
  name                = "Tf-publicip"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Network interface
resource "azurerm_network_interface" "NIC" {
  name                = "TF-NIC"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "TF-IP"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_network_security_group" "NSG" {
  name                = "Tf-NSG"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name


  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    /*resource_group_name         = azurerm_resource_group.RG
    network_security_group_name = azurerm_network_security_group.NSG.name*/
  }
  security_rule {
    name                       = "Tf-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    /*resource_group_name         = azurerm_resource_group.RG
    network_security_group_name = azurerm_network_security_group.NSG.name*/
  }
}

resource "azurerm_network_interface_security_group_association" "NIC_association" {
  network_interface_id      = azurerm_network_interface.NIC.id
  network_security_group_id = azurerm_network_security_group.NSG.idyes
}

resource "azurerm_linux_virtual_machine" "Tf-VM" {
    name                            = "Tf-Linux-machine"
    resource_group_name             = azurerm_resource_group.RG.name
    location                        = azurerm_resource_group.RG.location
    size                            = "Standard_B2s"
    admin_username                  = "sa"
    admin_password                  = "Daredevil@$98"
    network_interface_ids           = [azurerm_network_interface.NIC.id]
    disable_password_authentication = false
    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    }

source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
}

provisioner "remote-exec" {
    inline = [
        "ufw allow OpenSSH && ufw enable -y",
        "sudo apt update",
        "sudo apt install apache2 -y",
        "sudo ufw allow apache",
        "echo '<h1><center>My first website using terraform provisioner</center><h1>'>index.html",
        "echo '<h1><center>using Terraforn</center><h1>'>> index.html",
        "sudo mv index.html /var/www/html/"
    ]

    connection {
        type     = "ssh"
        host     = azurerm_public_ip.publicip.ip_address
        user     = "sa"
        password = "Daredevil@$98"
    }
  }
}
