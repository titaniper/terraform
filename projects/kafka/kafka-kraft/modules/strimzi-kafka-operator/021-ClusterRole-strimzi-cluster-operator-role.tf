# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/021-ClusterRole-strimzi-cluster-operator-role.yaml

resource "kubernetes_cluster_role" "global" {
  metadata {
    name      = "${var.name}-global"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = [
      # The cluster operator needs to create and manage cluster role bindings in the case of an install where a user
      # has specified they want their cluster role bindings generated
      "clusterrolebindings"
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = [
      # The cluster operator requires "get" permissions to view storage class details
      # This is because only a persistent volume of a supported storage class type can be resized
      "storageclasses"
    ]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = [
      # The cluster operator requires "list" permissions to view all nodes in a cluster
      # The listing is used to determine the node addresses when NodePort access is configured
      # These addresses are then exposed in the custom resource states
      "nodes"
    ]
    verbs      = ["list"]
  }
}
