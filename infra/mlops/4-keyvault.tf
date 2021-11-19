resource "azurecaf_name" "kv" {
  name     = "${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_type = "azurerm_key_vault"
  random_length = var.random_length
}

resource "azurerm_key_vault" "kv" {
  name                     = azurecaf_name.kv.result
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  enabled_for_disk_encryption = true

  purge_protection_enabled = true

  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id =  data.azurerm_client_config.current.object_id

    key_permissions = [
      "backup", "create", "delete", "get", "import", "list", "recover", "restore", "update"
    ]

    secret_permissions = [
      "backup", "delete", "get", "list", "recover", "restore", "set"
    ]

    certificate_permissions = [
      "backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"
    ]
  }

}

resource "azurecaf_name" "kv-pe" {
  name     = "kv-${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_types = [
    "azurerm_private_endpoint",
    "azurerm_private_dns_zone_virtual_network_link"
  ]
  random_length = var.random_length
}

resource "azurerm_private_dns_zone" "kv" {
  # Note: To use a private zone to override the default DNS resolution 
  # for KV, the zone must be named privatelink.vaultcore.azure.net
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name                  = azurecaf_name.kv-pe.results["azurerm_private_dns_zone_virtual_network_link"]
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = data.azurerm_virtual_network.net.id
}

resource "azurerm_private_endpoint" "kv" {
  name                = azurecaf_name.kv-pe.results["azurerm_private_endpoint"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.net.id

  private_service_connection {
    name                           = azurecaf_name.kv-pe.results["azurerm_private_endpoint"]
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  # Note: KV has a DNS configuration for a public endpoint that needs to be overriden.
  private_dns_zone_group {
    name                 = azurecaf_name.kv-pe.results["azurerm_private_endpoint"]
    private_dns_zone_ids = [azurerm_private_dns_zone.kv.id]
  }
}
