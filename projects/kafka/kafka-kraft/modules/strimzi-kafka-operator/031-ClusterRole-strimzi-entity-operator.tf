# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/031-ClusterRole-strimzi-entity-operator.yaml

resource "kubernetes_cluster_role" "entity" {
  metadata {
    name      = "${var.name}-entity"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = ["kafka.strimzi.io"]
    resources  = [
      # The entity operator runs the KafkaTopic assembly operator, which needs to access and manage KafkaTopic resources
      "kafkatopics",
      "kafkatopics/status",
      # The entity operator runs the KafkaUser assembly operator, which needs to access and manage KafkaUser resources
      "kafkausers",
      "kafkausers/status",
    ]
    verbs      = ["get", "list", "watch", "create", "patch", "update", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = [
      "create" # The entity operator needs to be able to create events
    ]
  }

  rule {
    api_groups = [""]
    # The entity operator user-operator needs to access and manage secrets to store generated credentials
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
}
