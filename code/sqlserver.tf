data "azurerm_key_vault" "kv" {
  resource_group_name = "state-nprd-rg"
  name                = "ecmasharedkv"
}

data "azurerm_key_vault_secret" "username" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "ecma-dev-username"
}

data "azurerm_key_vault_secret" "secret" {
  key_vault_id = data.azurerm_key_vault.kv.id
  name         = "ecma-dev-secret"
}

resource "azurerm_mssql_server" "primary_server" {
  name                         = local.app_name_with_env
  resource_group_name          = azurerm_resource_group.primary.name
  location                     = azurerm_resource_group.primary.location
  version                      = "12.0"
  administrator_login          = data.azurerm_key_vault_secret.username.value
  administrator_login_password = data.azurerm_key_vault_secret.secret.value

  azuread_administrator {
    login_username = "learner-ad"
    object_id      = "b33c7c69-6989-42a1-a443-a1f7322a041e"
  }

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  name             = "AllowAzureResources"
  server_id        = azurerm_mssql_server.primary_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "sql_admin_firewall_rule" {
  name             = "faraz ip address"
  server_id        = azurerm_mssql_server.primary_server.id
  start_ip_address = "106.202.159.166"
  end_ip_address   = "106.202.159.166"
}

resource "azurerm_mssql_database" "primary_db" {
  name      = local.app_name_with_sub_env
  server_id = azurerm_mssql_server.primary_server.id

  tags = var.tags
}

resource "azurerm_mssql_database_extended_auditing_policy" "extended_policy" {
  database_id                             = azurerm_mssql_database.primary_db.id
  storage_endpoint                        = azurerm_storage_account.sa.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.sa.primary_access_key
  storage_account_access_key_is_secondary = true
  retention_in_days                       = 6
}