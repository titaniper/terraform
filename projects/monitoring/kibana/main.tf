terraform {
  required_version = ">= 1.0.0"
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~>0.9"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  elasticsearch_name = "elasticsearch"
  namespace          = "monitoring"
}


# provider "elasticstack" {
#   elasticsearch {
#     username  = "elastic"
#     password  = "hk85tdH35c4BmQYq0s934L0E"
#     endpoints = ["http://localhost:30092"]
#   }
#   kibana {
#     username  = "elastic"
#     password  = "hk85tdH35c4BmQYq0s934L0E"
#     endpoints = ["http://localhost:30601"]
#   }
# }
