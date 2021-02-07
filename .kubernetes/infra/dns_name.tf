variable "github_token" {}

output "dns_name" {
  value = azurerm_kubernetes_cluster.k8s.addon_profile.0.http_application_routing.0.http_application_routing_zone_name
}

provider "github" {
  token = var.github_token
}

resource "github_actions_secret" "example_secret" {
  repository      = "hss"
  secret_name     = "DNS_NAME"
  plaintext_value = azurerm_kubernetes_cluster.k8s.addon_profile.0.http_application_routing.0.http_application_routing_zone_name
}