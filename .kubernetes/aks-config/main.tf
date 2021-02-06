

provider "kubernetes" {
  config_path    = "../.kube/config"
}

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x. 
  # If you are using version 1.x, the "features" block is not allowed.
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "github-actions-infra-state"
    storage_account_name = "ghainfratfstate"
    container_name       = "terraform-state"
    key                  = "aks-config.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "k8s" {
  name                = var.cluster_name
  resource_group_name = data.azurerm_resource_group.k8s.name
}

data "azurerm_resource_group" "k8s" {
  name     = var.resource_group_name
}


resource "random_id" "event_hub_name_suffix" {
  byte_length = 2
}


resource "azurerm_eventhub_namespace" "example" {
  name                = "acceptanceTestEventHubNamespace-${random_id.event_hub_name_suffix.dec}"
  location            = data.azurerm_resource_group.k8s.location
  resource_group_name = data.azurerm_resource_group.k8s.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    Environment = "Development"
  }
}

resource "azurerm_eventhub" "example" {
  name                = "acceptanceTestEventHub-${random_id.event_hub_name_suffix.dec}"
  namespace_name      = azurerm_eventhub_namespace.example.name
  resource_group_name = data.azurerm_resource_group.k8s.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "example" {
  name                = "navi"
  namespace_name      = azurerm_eventhub_namespace.example.name
  eventhub_name       = azurerm_eventhub.example.name
  resource_group_name = data.azurerm_resource_group.k8s.name
  listen              = true
  send                = true
  manage              = false
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "aks-eventhub-con-string"
  }

  data = {
    connectionstring = azurerm_eventhub_authorization_rule.example.primary_connection_string
  }

  type = "Opaque"

}



output "http_application_routing_zone_name" {
  value = data.azurerm_kubernetes_cluster.k8s.addon_profile[0].http_application_routing[0].http_application_routing_zone_name
}
