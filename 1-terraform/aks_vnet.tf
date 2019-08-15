
#Creating the AKS Vnet

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks_vnet_name
  resource_group_name = azurerm_resource_group.aks_demo_rg.name
  location            = azurerm_resource_group.aks_demo_rg.location
  address_space       = ["10.0.0.0/12"]
} 

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks_subnet"
  resource_group_name  = azurerm_resource_group.aks_demo_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefix       = "10.1.0.0/16"
}

#Role Assignment to give AKS the access to VNET - Required for Advanced Networking
# resource "azurerm_role_assignment" "aks-vnet-role" {
#   scope                = azurerm_virtual_network.aks_vnet.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azuread_service_principal.spn.id
# }
