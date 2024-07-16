# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/022-RoleBinding-strimzi-cluster-operator.yaml

resource "kubernetes_role_binding" "leader-election" {
  metadata {
    name      = "${var.name}-leader-election"
    namespace = var.namespace
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
    name      = kubernetes_cluster_role.leader-election.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
}
