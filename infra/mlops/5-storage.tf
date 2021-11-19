resource "azurecaf_name" "sa" {
  name     = "${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_type = "azurerm_storage_account"
  random_length = var.random_length
}

resource "azurerm_storage_account" "sa" {
  name                     = azurecaf_name.sa.result
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"

  network_rules {
    default_action             = "Deny"
    bypass                     = ["Logging", "Metrics", "AzureServices"]
  }
}

# blob storage connection
resource "azurecaf_name" "sablob-pe" {
  name     = "sablob-${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_types = [
    "azurerm_private_endpoint",
    "azurerm_private_dns_zone_virtual_network_link"
  ]
  random_length = var.random_length
}

resource "azurerm_private_dns_zone" "sablob" {
  # Note: To use a private zone to override the default DNS resolution 
  # for sa, the zone must be named privatelink.blob.core.windows.net
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sablob" {
  name                  = azurecaf_name.sablob-pe.results["azurerm_private_dns_zone_virtual_network_link"]
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sablob.name
  virtual_network_id    = data.azurerm_virtual_network.net.id
}

resource "azurerm_private_endpoint" "sablob" {
  name                = azurecaf_name.sablob-pe.results["azurerm_private_endpoint"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.net.id

  private_service_connection {
    name                           = azurecaf_name.sablob-pe.results["azurerm_private_endpoint"]
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  # Note: sa has a DNS configuration for a public endpoint that needs to be overriden.
  private_dns_zone_group {
    name                 = azurecaf_name.sablob-pe.results["azurerm_private_endpoint"]
    private_dns_zone_ids = [azurerm_private_dns_zone.sablob.id]
  }
}

# file storage connection
resource "azurecaf_name" "safile-pe" {
  name     = "safile-${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_types = [
    "azurerm_private_endpoint",
    "azurerm_private_dns_zone_virtual_network_link"
  ]
  random_length = var.random_length
}

resource "azurerm_private_dns_zone" "safile" {
  # Note: To use a private zone to override the default DNS resolution 
  # for sa, the zone must be named privatelink.blob.core.windows.net
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "safile" {
  name                  = azurecaf_name.safile-pe.results["azurerm_private_dns_zone_virtual_network_link"]
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.safile.name
  virtual_network_id    = data.azurerm_virtual_network.net.id
}

resource "azurerm_private_endpoint" "safile" {
  name                = azurecaf_name.safile-pe.results["azurerm_private_endpoint"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.net.id

  private_service_connection {
    name                           = azurecaf_name.safile-pe.results["azurerm_private_endpoint"]
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  # Note: sa has a DNS configuration for a public endpoint that needs to be overriden.
  private_dns_zone_group {
    name                 = azurecaf_name.safile-pe.results["azurerm_private_endpoint"]
    private_dns_zone_ids = [azurerm_private_dns_zone.safile.id]
  }
}
