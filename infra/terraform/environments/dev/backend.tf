terraform {
  backend "azurerm" {
    resource_group_name  = "rg-devops-lab-tfstate-ilc"
    storage_account_name = "REPLACE_WITH_BOOTSTRAP_OUTPUT"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
    use_azuread_auth     = true
  }
}