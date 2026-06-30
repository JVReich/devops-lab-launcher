output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_id" {
  value = module.resource_group.id
}

output "vnet_name" {
  value = module.virtual_network.vnet_name
}

output "aks_subnet_id" {
  value = module.virtual_network.subnet_id
}