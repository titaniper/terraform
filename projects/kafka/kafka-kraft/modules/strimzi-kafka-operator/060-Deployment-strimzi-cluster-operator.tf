# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/060-Deployment-strimzi-cluster-operator.yaml

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_service_account.this.metadata.0.namespace
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "strimzi-kafka-operator"
        "app.kubernetes.io/instance" = var.name
        "strimzi.io/kind"            = "cluster-operator"
      }
    }

    template {
      metadata {
        labels                         = {
          "app.kubernetes.io/name"     = "strimzi-kafka-operator"
          "app.kubernetes.io/instance" = var.name
          "strimzi.io/kind"            = "cluster-operator"
        }

        # https://github.com/strimzi/strimzi-kafka-operator/blob/main/examples/metrics/prometheus-install/strimzi-pod-monitor.yaml
        annotations              = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/port"   = "http"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.this.metadata.0.name
        automount_service_account_token = true

        volume {
          name = "strimzi-tmp"
          empty_dir {
            medium     = "Memory"
            size_limit = "1Mi"
          }
        }

        volume {
          name = "co-config-volume"
          config_map {
            name = kubernetes_config_map.this.metadata.0.name
          }
        }

        container {
          name  = "strimzi-cluster-operator"
          image = "quay.io/strimzi/operator:${var.operator_version}"

          port {
            container_port = 8080
            name           = "http"
          }

          args = [
            "/opt/strimzi/bin/cluster_operator_run.sh"
          ]

          volume_mount {
            name       = "strimzi-tmp"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "co-config-volume"
            mount_path = "/opt/strimzi/custom-config/"
          }

          env {
            name = "STRIMZI_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "STRIMZI_FULL_RECONCILIATION_INTERVAL_MS"
            value = "120000"
          }

          env {
            name  = "STRIMZI_OPERATION_TIMEOUT_MS"
            value = "300000"
          }

          env {
            name  = "STRIMZI_DEFAULT_TLS_SIDECAR_ENTITY_OPERATOR_IMAGE"
            value = "quay.io/strimzi/kafka:${var.operator_version}-kafka-${var.kafka_version}"
          }

          env {
            name  = "STRIMZI_DEFAULT_KAFKA_EXPORTER_IMAGE"
            value = "quay.io/strimzi/kafka:${var.operator_version}-kafka-${var.kafka_version}"
          }

          env {
            name  = "STRIMZI_DEFAULT_CRUISE_CONTROL_IMAGE"
            value = "quay.io/strimzi/kafka:${var.operator_version}-kafka-${var.kafka_version}"
          }

          env {
            name  = "STRIMZI_KAFKA_IMAGES"
            value = <<EOT
${join("\n", [for v in var.supported_kafka_versions : "${v}=quay.io/strimzi/kafka:${var.operator_version}-kafka-${v}"])}
EOT
          }

          env {
            name  = "STRIMZI_KAFKA_CONNECT_IMAGES"
            value = <<EOT
${join("\n", [for v in var.supported_kafka_versions : "${v}=quay.io/strimzi/kafka:${var.operator_version}-kafka-${v}"])}
EOT
          }

          env {
            name  = "STRIMZI_KAFKA_MIRROR_MAKER_IMAGES"
            value = <<EOT
${join("\n", [for v in var.supported_kafka_versions : "${v}=quay.io/strimzi/kafka:${var.operator_version}-kafka-${v}"])}
EOT
          }

          env {
            name  = "STRIMZI_KAFKA_MIRROR_MAKER_2_IMAGES"
            value = <<EOT
${join("\n", [for v in var.supported_kafka_versions : "${v}=quay.io/strimzi/kafka:${var.operator_version}-kafka-${v}"])}
EOT
          }

          env {
            name  = "STRIMZI_DEFAULT_TOPIC_OPERATOR_IMAGE"
            value = "quay.io/strimzi/operator:${var.operator_version}"
          }

          env {
            name  = "STRIMZI_DEFAULT_USER_OPERATOR_IMAGE"
            value = "quay.io/strimzi/operator:${var.operator_version}"
          }

          env {
            name  = "STRIMZI_DEFAULT_KAFKA_INIT_IMAGE"
            value = "quay.io/strimzi/operator:${var.operator_version}"
          }

          env {
            name  = "STRIMZI_DEFAULT_KAFKA_BRIDGE_IMAGE"
            value = "quay.io/strimzi/kafka-bridge:0.26.1"
          }

          env {
            name  = "STRIMZI_DEFAULT_KANIKO_EXECUTOR_IMAGE"
            value = "quay.io/strimzi/kaniko-executor:${var.operator_version}"
          }

          env {
            name  = "STRIMZI_DEFAULT_MAVEN_BUILDER"
            value = "quay.io/strimzi/maven-builder:${var.operator_version}"
          }

          env {
            name = "STRIMZI_OPERATOR_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name  = "STRIMZI_FEATURE_GATES"
            value = ""
          }

          env {
            name  = "STRIMZI_LEADER_ELECTION_ENABLED"
            value = "true"
          }

          env {
            name  = "STRIMZI_LEADER_ELECTION_LEASE_NAME"
            value = "strimzi-cluster-operator"
          }

          env {
            name = "STRIMZI_LEADER_ELECTION_LEASE_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          env {
            name = "STRIMZI_LEADER_ELECTION_IDENTITY"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/healthy"
              port = "http"
            }

            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "http"
            }

            initial_delay_seconds = 10
            period_seconds        = 30
          }

          resources {
            limits   = {
              # cpu    = "1"
              memory = "384Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "384Mi"
            }
          }
        }
      }
    }
  }
}
