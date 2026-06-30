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

  virtual_network = {
    name          = module.naming.vnet_name
    address_space = var.virtual_network.address_space
  }

  aks_subnet = {
    name             = module.naming.subnet_name
    address_prefixes = var.virtual_network.aks_subnet_prefixes
  }

  tags = local.common_tags
}

module "aks" {
  source = "../../modules/aks"

  location            = var.environment_config.location
  resource_group_name = module.resource_group.name

  cluster = {
    name                = module.naming.aks_name
    dns_prefix          = module.naming.aks_name
    kubernetes_version  = var.kubernetes_cluster.kubernetes_version
    node_resource_group = module.naming.aks_node_rg_name
  }

  default_node_pool = {
    node_count = var.kubernetes_cluster.node_count
    vm_size    = var.kubernetes_cluster.vm_size
    subnet_id  = module.virtual_network.subnet_id
  }

  tags = local.common_tags
}