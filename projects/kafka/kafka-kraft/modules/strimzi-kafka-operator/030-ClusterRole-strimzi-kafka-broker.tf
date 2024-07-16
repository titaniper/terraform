# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/030-ClusterRole-strimzi-kafka-broker.yaml

resource "kubernetes_cluster_role" "broker" {
  metadata {
    name      = "${var.name}-broker"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [""]
    # The Kafka Brokers require "get" permissions to view the node they are on
    # This information is used to generate a Rack ID that is used for High Availability configurations
    resources  = ["nodes"]
    verbs      = ["get"]
  }
}
