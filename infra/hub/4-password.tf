# Create Random Password
resource "random_password" "azdo-password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "keyvault_ado_agent_secret" {
  name         = "azdo-agent-password-1"
  value        = random_password.azdo-password.result
  key_vault_id = var.key_vault_id
}
