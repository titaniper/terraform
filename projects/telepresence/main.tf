resource "kubernetes_namespace" "telepresence" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "telepresence" {
  name       = "traffic-manager"
  namespace  = kubernetes_namespace.telepresence.metadata[0].name
  repository = "https://app.getambassador.io"
  chart      = "telepresence"
  #   version    = "13.0.0" # Adjust to the latest version if needed

  set {
    name  = "createCustomResources"
    value = "true"
  }
}
