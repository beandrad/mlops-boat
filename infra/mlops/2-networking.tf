resource "azurecaf_name" "net" {
  name     = var.name
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_types = [
    "azurerm_virtual_network",
    "azurerm_subnet"
  ]
  random_length = var.random_length
}

data "azurerm_virtual_network" "net" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_rg_name
}


# resource "azurerm_virtual_network" "net" {
#   name                = azurecaf_name.net.results["azurerm_virtual_network"]
#   address_space       = var.vnet_address_space
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
# }

resource "azurerm_subnet" "net" {
  name                                           = azurecaf_name.net.results["azurerm_subnet"]
  resource_group_name                            = data.azurerm_virtual_network.net.resource_group_name
  virtual_network_name                           = data.azurerm_virtual_network.net.name
  address_prefixes                               = var.subnet_address_space
  enforce_private_link_endpoint_network_policies = true
}
