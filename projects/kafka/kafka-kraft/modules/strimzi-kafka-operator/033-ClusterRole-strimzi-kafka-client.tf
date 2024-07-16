# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/033-ClusterRole-strimzi-kafka-client.yaml

resource "kubernetes_cluster_role" "client" {
  metadata {
    name      = "${var.name}-client"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [""]
    # The Kafka clients (Connect, Mirror Maker, etc.) require "get" permissions to view the node they are on
    # This information is used to generate a Rack ID (client.rack option) that is used for consuming from the closest
    # replicas when enabled
    resources  = ["nodes"]
    verbs      = ["get"]
  }
}
