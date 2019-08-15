resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = var.resource_group
  location                 = var.azure_region
  sku                      = "Basic"
  admin_enabled            = false
}