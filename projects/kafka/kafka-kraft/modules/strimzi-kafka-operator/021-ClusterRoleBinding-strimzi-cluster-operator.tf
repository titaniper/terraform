# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/021-ClusterRoleBinding-strimzi-cluster-operator.yaml

resource "kubernetes_cluster_role_binding" "global" {
  metadata {
    name      = "${var.name}-global"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata.0.name
    namespace = kubernetes_service_account.this.metadata.0.namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.global.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
}
