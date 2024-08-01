locals {
    main_vnet {
    name = "${local.resource_name_prefix}-vnet-${random_string.myrandom.id}"
    address_space = ["10.0.0.0/16"]
    }
}

resource "azurerm_virtual_network" "main_vnet" {
    name = local.main_vnet.name
    location = var.resource_group_location
    resource_group_name = azurerm_resource_group.Resource_Group_01.name
    address_space = local.main_vnet.address_space
}
