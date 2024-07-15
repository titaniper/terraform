resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "kafka-ui"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "kafka-ui"
        "app.kubernetes.io/instance" = var.name
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"     = "kafka-ui"
          "app.kubernetes.io/instance" = var.name
        }
      }

      spec {
        container {
          name  = "kafka-ui"
          image = "docker.io/provectuslabs/kafka-ui"

          env {
            name  = "KAFKA_CLUSTERS_0_NAME"
            value = "kafka"
          }
          env {
            name  = "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS"
            value = "kafka-kafka-bootstrap.streaming.svc.cluster.local:9092"
          }
          env {
            name  = "SPRING_CONFIG_LOCATION"
            value = "/kafka-ui/config.yml"
          }

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }
          liveness_probe {
            http_get {
              path = "/actuator/health"
              port = "http"
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 10
          }
          readiness_probe {
            http_get {
              path = "/actuator/health"
              port = "http"
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 10
          }
          #   resources:
          #     {{- toYaml .Values.resources | nindent 12 }}
          volume_mount {
            name       = "kafka-ui-yaml-conf"
            mount_path = "/kafka-ui/"
          }
        }

        volume {
          name = "kafka-ui-yaml-conf"
          config_map {
            name = kubernetes_config_map.this.metadata.0.name
          }
        }
      }
    }
  }
}
