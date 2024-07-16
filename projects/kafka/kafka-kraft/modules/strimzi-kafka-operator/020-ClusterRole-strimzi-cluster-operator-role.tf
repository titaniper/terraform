# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/install/cluster-operator/020-ClusterRole-strimzi-cluster-operator-role.yaml

resource "kubernetes_cluster_role" "namespaced" {
  metadata {
    name      = "${var.name}-namespaced"
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  # Resources in this role are used by the operator based on an operand being deployed in some namespace. When needed, you
  # can deploy the operator as a cluster-wide operator. But grant the rights listed in this role only on the namespaces
  # where the operands will be deployed. That way, you can limit the access the operator has to other namespaces where it
  # does not manage any clusters.

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = [
      "rolebindings" # The cluster operator needs to access and manage rolebindings to grant Strimzi components cluster permissions
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = [
      "roles" # The cluster operator needs to access and manage roles to grant the entity operator permissions
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = [
      "pods", # The cluster operator needs to access and delete pods, this is to allow it to monitor pod health and coordinate rolling updates
      "serviceaccounts", # The cluster operator needs to access and manage service accounts to grant Strimzi components cluster permissions
      "configmaps", # The cluster operator needs to access and manage config maps for Strimzi components configuration
      "services", # The cluster operator needs to access and manage services and endpoints to expose Strimzi components to network traffic
      "endpoints",
      "secrets", # The cluster operator needs to access and manage secrets to handle credentials
      "persistentvolumeclaims", # The cluster operator needs to access and manage persistent volume claims to bind them to Strimzi components for persistent data
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }

  rule {
    api_groups = ["apps"]
    resources  = [
      # The cluster operator needs to access and manage deployments to run deployment based Strimzi components
      "deployments",
      "deployments/scale",
      "deployments/status",
      # The cluster operator needs to access and manage stateful sets to run stateful sets based Strimzi components
      "statefulsets",
      # The cluster operator needs to access replica-sets to manage Strimzi components and to determine error states
      "replicasets",
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
  rule {
    api_groups = [
      "",              # legacy core events api, used by topic operator
      "events.k8s.io", # new events api, used by cluster operator
    ]
    resources  = [
      "events" # The cluster operator needs to be able to create events and delegate permissions to do so
    ]
    verbs      = ["create"]
  }

  # rule {
  #   api_groups = [
  #     # Kafka Connect Build on OpenShift requirement
  #     "build.openshift.io"
  #   ]
  #   resources  = [
  #   - buildconfigs
  #   - buildconfigs/instantiate
  #   - builds
  #   verbs      = [
  #   - get
  #   - list
  #   - watch
  #   - create
  #   - delete
  #   - patch
  #   - update
  # }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = [
      "networkpolicies", # The cluster operator needs to access and manage network policies to lock down communication between Strimzi components
      "ingresses", # The cluster operator needs to access and manage ingresses which allow external access to the services in a cluster
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }

  # rule {
  #   api_groups = ["route.openshift.io"]
  #   resources  = [
  #     # The cluster operator needs to access and manage routes to expose Strimzi components for external access
  #   - routes
  #   - routes/custom-host
  #   verbs      = [
  #   - get
  #   - list
  #   - watch
  #   - create
  #   - delete
  #   - patch
  #   - update
  # }

  # rule {
  #   api_groups = ["image.openshift.io"]
  #   resources  = [
  #   # The cluster operator needs to verify the image stream when used for Kafka Connect image build
  #   - imagestreams
  #   verbs      = [
  #   - get
  # }

  rule {
    api_groups = ["policy"]
    resources  = [
      # The cluster operator needs to access and manage pod disruption budgets this limits the number of concurrent disruptions
      # that a Strimzi component experiences, allowing for higher availability
      "poddisruptionbudgets"
    ]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
}
