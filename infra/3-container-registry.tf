resource "azurecaf_name" "acr" {
  name     = var.name
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_types = [
    "azurerm_container_registry",
    "azurerm_private_endpoint",
    "azurerm_private_dns_zone_virtual_network_link"
  ]
  random_length = var.random_length
}

resource "azurerm_container_registry" "acr" {
  name                = azurecaf_name.acr.results["azurerm_container_registry"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true
  network_rule_set {
    default_action = "Deny"
  }
}

resource "azurerm_private_dns_zone" "acr" {
  # Note: To use a private zone to override the default DNS resolution 
  # for ACR, the zone must be named privatelink.azurecr.io
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = azurecaf_name.acr.results["azurerm_private_dns_zone_virtual_network_link"]
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.net.id
}

resource "azurerm_private_endpoint" "acr" {
  name                = azurecaf_name.acr.results["azurerm_private_endpoint"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.net.id

  private_service_connection {
    name                           = azurecaf_name.acr.results["azurerm_private_endpoint"]
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  # Note: ACR has a DNS configuration for a public endpoint that needs to be overriden.
  private_dns_zone_group {
    name                 = azurecaf_name.acr.results["azurerm_private_endpoint"]
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }
}
