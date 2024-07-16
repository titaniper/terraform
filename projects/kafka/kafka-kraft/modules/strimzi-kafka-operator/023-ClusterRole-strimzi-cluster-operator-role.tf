# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/023-ClusterRole-strimzi-cluster-operator-role.yaml

resource "kubernetes_cluster_role" "watched" {
  metadata {
    name      = "${var.name}-watched"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  # Resources in this role are being watched by the operator. When operator is deployed as cluster-wide, these permissions
  # need to be granted to the operator on a cluster wide level as well, even if the operands will be deployed only in
  # few of the namespaces in given cluster. This is required to set up the Kubernetes watches and informers.
  # Note: The rights included in this role might change in the future

  rule {
    api_groups = [""]
    resources  = [
      "pods" # The cluster operator needs to access and delete pods, this is to allow it to monitor pod health and coordinate rolling updates
    ]
    verbs      = ["watch", "list"]
  }

  rule {
    api_groups = ["kafka.strimzi.io"]
    resources  = [
      # The cluster operator runs the KafkaAssemblyOperator, which needs to access and manage Kafka resources
      "kafkas",
      "kafkas/status",
      # The cluster operator runs the KafkaAssemblyOperator, which needs to access and manage KafkaNodePool resources
      "kafkanodepools",
      "kafkanodepools/status",
      # The cluster operator runs the KafkaConnectAssemblyOperator, which needs to access and manage KafkaConnect resources
      "kafkaconnects",
      "kafkaconnects/status",
      # The cluster operator runs the KafkaConnectorAssemblyOperator, which needs to access and manage KafkaConnector resources
      "kafkaconnectors",
      "kafkaconnectors/status",
      # The cluster operator runs the KafkaMirrorMakerAssemblyOperator, which needs to access and manage KafkaMirrorMaker resources
      "kafkamirrormakers",
      "kafkamirrormakers/status",
      # The cluster operator runs the KafkaBridgeAssemblyOperator, which needs to access and manage BridgeMaker resources
      "kafkabridges",
      "kafkabridges/status",
      # The cluster operator runs the KafkaMirrorMaker2AssemblyOperator, which needs to access and manage KafkaMirrorMaker2 resources
      "kafkamirrormaker2s",
      "kafkamirrormaker2s/status",
      # The cluster operator runs the KafkaRebalanceAssemblyOperator, which needs to access and manage KafkaRebalance resources
      "kafkarebalances",
      "kafkarebalances/status",
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }

  rule {
    api_groups = ["core.strimzi.io"]
    resources  = [
      # The cluster operator uses StrimziPodSets to manage the Kafka and ZooKeeper pods
      "strimzipodsets",
      "strimzipodsets/status",
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
}
