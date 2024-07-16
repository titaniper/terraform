# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/022-ClusterRole-strimzi-cluster-operator-role.yaml

resource "kubernetes_cluster_role" "leader-election" {
  metadata {
    name      = "${var.name}-leader-election"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = [
      # The cluster operator needs to access and manage leases for leader election
      # The "create" verb cannot be used with "resourceNames"
      "leases"
    ]
    verbs = ["create"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = [
      # The cluster operator needs to access and manage leases for leader election
      "leases"
    ]
    resource_names = [
      # The default RBAC files give the operator only access to the Lease resource names strimzi-cluster-operator
      # If you want to use another resource name or resource namespace, you have to configure the RBAC resources accordingly
      "strimzi-cluster-operator"
    ]
    verbs = ["get", "list", "watch", "delete", "patch", "update"]
  }
}
