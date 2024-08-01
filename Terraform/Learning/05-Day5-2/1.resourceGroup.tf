resource "azurerm_resource_group" "Resource_Group_01" {
  name = "${local.resource_name_prefix}-${var.resource_group_name}-${ramdom_string.myrandom.id}"
  location = var.resource_group_location
}