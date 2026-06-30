output "vnet_id" {
  description = "Virtual Network ID."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual Network name."
  value       = azurerm_virtual_network.this.name
}

output "subnet_id" {
  description = "AKS subnet ID."
  value       = azurerm_subnet.aks.id
}

output "subnet_name" {
  description = "AKS subnet name."
  value       = azurerm_subnet.aks.name
}