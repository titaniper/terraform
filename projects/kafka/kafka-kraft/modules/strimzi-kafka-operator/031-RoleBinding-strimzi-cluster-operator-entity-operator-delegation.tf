# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/031-RoleBinding-strimzi-cluster-operator-entity-operator-delegation.yaml

resource "kubernetes_role_binding" "entity" {
  metadata {
    name      = "${var.name}-entity"
    namespace = var.namespace
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  # The Entity Operator cluster role must be bound to the cluster operator service account so that it can delegate the cluster role to the Entity Operator.
  # This must be done to avoid escalating privileges which would be blocked by Kubernetes.

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata.0.name
    namespace = kubernetes_service_account.this.metadata.0.namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.entity.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
}
