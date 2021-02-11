

provider "kubernetes" {
  config_path = var.context_config
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
  name = var.resource_group_name
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

resource "azurerm_eventhub" "example-output" {
  name                = "acceptanceTestEventHub-${random_id.event_hub_name_suffix.dec}-output"
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


resource "kubernetes_secret" "aks-eventhub-con-string" {
  metadata {
    name      = "aks-eventhub-con-string"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  data = {
    connectionstring = azurerm_eventhub_authorization_rule.example.primary_connection_string
  }

  type = "Opaque"


}

resource "kubernetes_secret" "aks-eventhub-con-string-output" {
  metadata {
    name      = "aks-eventhub-con-string-output"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  data = {
    connectionstring = azurerm_eventhub_authorization_rule.example-output.primary_connection_string
  }

  type = "Opaque"


}

resource "kubernetes_secret" "aks-eventhub-name" {
  metadata {
    name      = "aks-eventhub-name"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  data = {
    name = azurerm_eventhub.example.name
  }

  type = "Opaque"

}



resource "kubernetes_secret" "aks-eventhub-name-output" {
  metadata {
    name      = "aks-eventhub-name-output"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  data = {
    name = azurerm_eventhub.example-output.name
  }

  type = "Opaque"

}







resource "kubernetes_secret" "aks-eventhub-con-string-staging" {
  metadata {
    name      = "aks-eventhub-con-string"
    namespace = kubernetes_namespace.example-staging.metadata[0].name
  }

  data = {
    connectionstring = azurerm_eventhub_authorization_rule.example.primary_connection_string
  }

  type = "Opaque"


}

resource "kubernetes_secret" "aks-eventhub-con-string-output-staging" {
  metadata {
    name      = "aks-eventhub-con-string-output"
    namespace = kubernetes_namespace.example-staging.metadata[0].name
  }

  data = {
    connectionstring = azurerm_eventhub_authorization_rule.example-output.primary_connection_string
  }

  type = "Opaque"


}

resource "kubernetes_secret" "aks-eventhub-name-staging" {
  metadata {
    name      = "aks-eventhub-name"
    namespace = kubernetes_namespace.example-staging.metadata[0].name
  }

  data = {
    name = azurerm_eventhub.example.name
  }

  type = "Opaque"

}



resource "kubernetes_secret" "aks-eventhub-name-output-staging" {
  metadata {
    name      = "aks-eventhub-name-output"
    namespace = kubernetes_namespace.example-staging.metadata[0].name
  }

  data = {
    name = azurerm_eventhub.example-output.name
  }

  type = "Opaque"

}








resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = var.namespace
  }
}


resource "kubernetes_namespace" "example-staging" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "staging"
  }
}



output "http_application_routing_zone_name" {
  value = data.azurerm_kubernetes_cluster.k8s.addon_profile[0].http_application_routing[0].http_application_routing_zone_name
}



resource "azurerm_stream_analytics_job" "example" {
  name                                     = "example-job"
  resource_group_name                      = data.azurerm_resource_group.k8s.name
  location                                 = data.azurerm_resource_group.k8s.location
  compatibility_level                      = "1.1"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 1

  tags = {
    environment = "Development"
  }

  transformation_query = <<QUERY
    SELECT Day, AVG(TemperatureC),MIN(TemperatureC),MAX(TemperatureC),STDEVP(TemperatureC)
    INTO [output-to-eventhub]
    FROM [eventhub-stream-input]
    GROUP BY Day, TumblingWindow(minute,5)  
QUERY

}



resource "azurerm_stream_analytics_output_eventhub" "example" {
  name                      = "output-to-eventhub"
  stream_analytics_job_name = azurerm_stream_analytics_job.example.name
  resource_group_name       = azurerm_stream_analytics_job.example.resource_group_name
  eventhub_name             = azurerm_eventhub.example-output.name
  servicebus_namespace      = azurerm_eventhub_namespace.example.name
  shared_access_policy_key  = azurerm_eventhub_namespace.example.default_primary_key
  shared_access_policy_name = "RootManageSharedAccessKey"

  serialization {
    type     = "Json"
    encoding = "UTF8"
    format   = "Array"
  }
}

resource "azurerm_eventhub_consumer_group" "example" {
  name                = "example-consumergroup"
  namespace_name      = azurerm_eventhub_namespace.example.name
  eventhub_name       = azurerm_eventhub.example.name
  resource_group_name = data.azurerm_resource_group.k8s.name
}


resource "azurerm_stream_analytics_stream_input_eventhub" "example" {
  name                         = "eventhub-stream-input"
  stream_analytics_job_name    = azurerm_stream_analytics_job.example.name
  resource_group_name          = azurerm_stream_analytics_job.example.resource_group_name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.example.name
  eventhub_name                = azurerm_eventhub.example.name
  servicebus_namespace         = azurerm_eventhub_namespace.example.name
  shared_access_policy_key     = azurerm_eventhub_namespace.example.default_primary_key
  shared_access_policy_name    = "RootManageSharedAccessKey"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}


resource "azurerm_eventhub_authorization_rule" "example-output" {
  name                = "navi"
  namespace_name      = azurerm_eventhub_namespace.example.name
  eventhub_name       = azurerm_eventhub.example-output.name
  resource_group_name = data.azurerm_resource_group.k8s.name
  listen              = true
  send                = false
  manage              = false
}