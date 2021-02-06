variable "agent_count" {
  default = 3
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "aks-temp"
}

variable "cluster_name" {
  default = "aks-temp"
}

variable "resource_group_name" {
  default = "aks-temp"
}

variable "location" {
  default = "westeurope"
}

variable "log_analytics_workspace_name" {
  default = "aks-temp-workspace"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable "log_analytics_workspace_location" {
  default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "github_token" {}