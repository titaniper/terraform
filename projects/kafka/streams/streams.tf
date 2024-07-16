resource "kubernetes_deployment" "kafka_streams" {
  metadata {
    name      = "kafka-streams-broadcast"
    namespace = kubernetes_namespace.streaming.metadata[0].name
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "kafka-streams-broadcast"
      }
    }

    template {
      metadata {
        labels = {
          app = "kafka-streams-broadcast"
        }
      }

      spec {
        container {
          name  = "kafka-streams-broadcast"
          image = "${var.docker_image}:${var.docker_tag}"

          port {
            container_port = 9092
          }

          env {
            name  = "COMMIT_HASH"
            value = "your-commit-hash"
          }

          env {
            name  = "NODE_ENV"
            value = "your-node-env"
          }

          env {
            name  = "KAFKA_BROKERS"
            value = var.kafka_brokers
          }

          liveness_probe {
            exec {
              command = ["/bin/sh", "-c", "test -f /tmp/healthy"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            exec {
              command = ["/bin/sh", "-c", "test -f /tmp/healthy"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# resource "kubernetes_service" "kafka_streams" {
#   metadata {
#     name      = "kafka-streams-broadcast"
#     namespace = kubernetes_namespace.streaming.metadata[0].name
#   }

#   spec {
#     selector = {
#       app = "kafka-streams-broadcast"
#     }

#     port {
#       protocol    = "TCP"
#       port        = 9092
#       target_port = 9092
#     }

#     type = "LoadBalancer"
#   }
# }
