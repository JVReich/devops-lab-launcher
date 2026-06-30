module "naming" {
  source = "../../modules/naming"

  project_name   = var.project_name
  environment    = var.environment
  location_short = var.location_short
}
module "resource_group" {
  source = "../../modules/resource-group"

  name     = module.naming.resource_group_name
  location = var.location

  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}