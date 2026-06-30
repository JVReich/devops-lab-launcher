resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster.dns_prefix

  kubernetes_version        = var.cluster.kubernetes_version
  node_resource_group       = var.cluster.node_resource_group
  sku_tier                  = "Free"
  azure_policy_enabled      = false
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "system"
    node_count     = var.default_node_pool.node_count
    vm_size        = var.default_node_pool.vm_size
    vnet_subnet_id = var.default_node_pool.subnet_id

    temporary_name_for_rotation = "tempnp"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  tags = var.tags
}