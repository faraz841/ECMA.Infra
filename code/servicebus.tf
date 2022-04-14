resource "azurerm_resource_group" "sb_primary" {
  name     = local.service_bus_namespace
  location = var.location
}

resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "ecma-servicebus-namespace"
  location            = azurerm_resource_group.sb_primary.location
  resource_group_name = azurerm_resource_group.sb_primary.name
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_role_assignment" "ecma_function_app_access" {
  scope                = azurerm_servicebus_namespace.sb_namespace.id
  role_definition_name = "Reader"
  principal_id         = azurerm_function_app.ecma_func_app.identity.0.principal_id
}
