provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you are using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "github-actions-infra-state"
    storage_account_name = "ghainfratfstate"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "aks-temp" {
  name     = "aks-temp"
  location = "westeurope"
}