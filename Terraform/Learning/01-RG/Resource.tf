resource "azurerm_virtual_network" "myVnet" {
  location            = azurerm_resource_group.my_demo_rg1.location
  resource_group_name = azurerm_resource_group.my_demo_rg1.name
  name                = "my-Vnet-1"
  address_space       = ["10.0.0.0/16"]
}

resource "random_string" "myRand" {
  length  = 16
  upper   = false
  lower   = false
  numeric = false
}

resource "azurerm_storage_account" "mysa" {
  name                     = "mysa${random_string.myRand.id}"
  resource_group_name      = azurerm_resource_group.my_demo_rg1.name
  location                 = azurerm_resource_group.my_demo_rg1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}