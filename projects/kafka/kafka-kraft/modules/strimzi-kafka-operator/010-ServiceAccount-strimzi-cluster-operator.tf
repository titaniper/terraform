# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/010-ServiceAccount-strimzi-cluster-operator.yaml

resource "kubernetes_service_account" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}
