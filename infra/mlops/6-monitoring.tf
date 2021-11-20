resource "azurecaf_name" "ins" {
  name          = var.name
  prefixes      = var.prefixes
  suffixes      = var.suffixes
  resource_type = "azurerm_application_insights"
  random_length = var.random_length
}

resource "azurerm_application_insights" "ins" {
  name                       = azurecaf_name.ins.result
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  application_type           = "web"
  # internet_ingestion_enabled = false
  # internet_query_enabled     = false
}

# TODO: add private link when supported by provider (`azurerm_monitor_private_link_scoped_service`).
