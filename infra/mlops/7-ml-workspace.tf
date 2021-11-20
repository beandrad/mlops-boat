resource "azurecaf_name" "mlws" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_machine_learning_workspace"
  random_length = var.random_length
}

resource "azurerm_machine_learning_workspace" "mlws" {
  name                    = azurecaf_name.mlws.result
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  container_registry_id   = azurerm_container_registry.acr.id
  key_vault_id            = azurerm_key_vault.kv.id
  storage_account_id      = azurerm_storage_account.sa.id
  application_insights_id = azurerm_application_insights.ins.id
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = false
}

# Two DNS zones: one for api and another one for 
resource "azurecaf_name" "mlws-api" {
  name     = "mlws-api-${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_type = "azurerm_private_dns_zone_virtual_network_link"
  random_length = var.random_length
}

resource "azurerm_private_dns_zone" "mlws-api" {
  # Note: To use a private zone to override the default DNS resolution 
  # for the Azure ML workspace API, the zone must be named privatelink.api.azureml.ms
  name                = "privatelink.api.azureml.ms"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mlws-api" {
  name                  = azurecaf_name.mlws-api.result
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mlws-api.name
  virtual_network_id    = data.azurerm_virtual_network.net.id
}

resource "azurecaf_name" "mlws-nb" {
  name     = "mlws-nb-${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_type = "azurerm_private_dns_zone_virtual_network_link"
  random_length = var.random_length
}

resource "azurerm_private_dns_zone" "mlws-nb" {
  # Note: To use a private zone to override the default DNS resolution 
  # for the Azure ML workspace jupyter/jupyterlab, the zone must be named privatelink.notebooks.azure.net
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mlws-nb" {
  name                  = azurecaf_name.mlws-nb.result
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mlws-nb.name
  virtual_network_id    = data.azurerm_virtual_network.net.id
}

resource "azurecaf_name" "mlws-pe" {
  name     = "mlws-${var.name}"
  prefixes = var.prefixes
  suffixes = var.suffixes
  resource_type = "azurerm_private_endpoint"
  random_length = var.random_length
}

resource "azurerm_private_endpoint" "mlws" {
  name                = azurecaf_name.mlws-pe.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.net.id

  private_service_connection {
    name                           = azurecaf_name.mlws-pe.result
    private_connection_resource_id = azurerm_machine_learning_workspace.mlws.id
    is_manual_connection           = false
    subresource_names              = ["amlworkspace"]
  }

  # Note: ML workspace has a DNS configuration for a public endpoint that needs to be overriden.
  private_dns_zone_group {
    name                 = azurecaf_name.mlws-pe.result
    private_dns_zone_ids = [azurerm_private_dns_zone.mlws-api.id, azurerm_private_dns_zone.mlws-nb.id]
  }
}
