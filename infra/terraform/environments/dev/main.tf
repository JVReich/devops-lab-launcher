locals {
  common_tags = {
    Project     = var.environment_config.project_name
    Environment = var.environment_config.environment
    ManagedBy   = "Terraform"
    Owner       = "JVReich"
    Repository  = "github.com/JVReich/devops-lab-launcher"
  }
}

module "naming" {
  source = "../../modules/naming"

  project_name   = var.environment_config.project_name
  environment    = var.environment_config.environment
  location_short = var.environment_config.location_short
}

module "resource_group" {
  source = "../../modules/resource-group"

  name     = module.naming.resource_group_name
  location = var.environment_config.location

  tags = local.common_tags
}

module "virtual_network" {
  source = "../../modules/virtual_network"

  resource_group_name = module.resource_group.name
  location            = var.environment_config.location

  vnet_name       = module.naming.vnet_name
  address_space   = var.virtual_network.address_space
  subnet_name     = module.naming.subnet_name
  subnet_prefixes = var.virtual_network.aks_subnet_prefixes

  tags = local.common_tags

}