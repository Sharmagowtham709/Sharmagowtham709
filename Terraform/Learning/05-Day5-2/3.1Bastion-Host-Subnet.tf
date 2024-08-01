# Resource-1: Create Bastion / Management Subnet
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.bastion_subnet_name}"
  resource_group_name  = azurerm_resource_group.Resource_Group_01.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = var.bastion_subnet_address
}

# Resource-2: Create Network Security Group (NSG)
resource "azurerm_network_security_group" "bastion_subnet_nsg" {
  name                = "${azurerm_subnet.bastion_subnet.name}-nsg"
  location            = azurerm_resource_group.Resource_Group_01.location
  resource_group_name = azurerm_resource_group.Resource_Group_01.name
}

# Resource-3: Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "bastion_subnet_nsg_associate" {
  depends_on                = [azurerm_network_security_rule.bastion_nsg_rule_inbound]
  subnet_id                 = azurerm_subnet.bastionsubnet.id
  network_security_group_id = azurerm_network_security_group.bastion_subnet_nsg.id
}

# Resource-4: Create NSG Rules
## Locals Block for Security Rules
locals {
  bastion_nsg_rule_inbound_defaults = {
    inbound_ports_map = {
      "100" : "22", # If the key starts with a number, you must use the colon syntax ":" instead of "="
      "110" : "3389"
    }
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"
    source_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}
## NSG Inbound Rule for Bastion / Management Subnets
resource "azurerm_network_security_rule" "bastion_nsg_rule_inbound" {
  for_each                    = local.bastion_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = local.bastion_nsg_rule_inbound_defaults.direction
  access                      = local.bastion_nsg_rule_inbound_defaults.direction
  protocol                    = local.bastion_nsg_rule_inbound_defaults.protocol
  source_port_range           = local.bastion_nsg_rule_inbound_defaults.source_port_range
  destination_port_range      = each.value
  source_address_prefix       = local.bastion_nsg_rule_inbound_defaults.source_address_prefix
  destination_address_prefix  = local.bastion_nsg_rule_inbound_defaults.destination_address_prefix
  resource_group_name         = azurerm_resource_group.Resource_Group_01.name
  network_security_group_name = azurerm_network_security_group.bastion_subnet_nsg.name
}
