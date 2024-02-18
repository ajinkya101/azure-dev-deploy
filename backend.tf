terraform {
  backend "azurerm" {
    resource_group_name  = "ndmilwkdevrsg"
    storage_account_name = "stg917213"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
