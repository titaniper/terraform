module "kafka-ui" {
  source    = "./modules/kubernetes/kafka-ui"
  name      = "kafka-ui"
  namespace = kubernetes_namespace.streaming.metadata[0].name
  clusters  = [kubernetes_manifest.kafka.manifest.metadata.name]

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
