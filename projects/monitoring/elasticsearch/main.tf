provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  elasticsearch_name = "elasticsearch"
  namespace          = "monitoring"
}

