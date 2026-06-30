locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.location_short}"

  resource_group_name = "rg-${local.name_prefix}"
  vnet_name           = "vnet-${local.name_prefix}"
  aks_name            = "aks-${local.name_prefix}"
  aks_node_rg_name    = "rg-${local.name_prefix}-aks-nodes"
}