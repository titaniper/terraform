locals {
  namespace    = "streaming"
  cluster_name = "kafka"
}

module "kafka-ui" {
  source    = "./modules/kubernetes/kafka-ui"
  name      = "kafka-ui"
  namespace = local.namespace
  clusters  = [local.cluster_name]

  service = {
    node_port = 30002
  }
  ingress = {
    host   = var.kafka_ui.ingress.host
    target = var.kafka_ui.ingress.target
  }
  oauth = {
    github = {
      client_id     = var.kafka_ui.oauth.github.client_id
      client_secret = var.kafka_ui.oauth.github.client_secret
      organization  = var.kafka_ui.oauth.github.organization
    }
  }
  users = var.kafka_ui.users
}
