provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "github-actions-infra-state-2"
    storage_account_name = "ghainfratfstate-2"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
  location = var.location
}


#provider "kubernetes" {
#  host = azurerm_kubernetes_cluster.k8s.kube_config.0.host

#  username = azurerm_kubernetes_cluster.k8s.kube_config.0.username
#  password = azurerm_kubernetes_cluster.k8s.kube_config.0.password
#}


