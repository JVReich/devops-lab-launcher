resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.virtual_network.address_space

  tags = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = var.aks_subnet.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.aks_subnet.address_prefixes
}