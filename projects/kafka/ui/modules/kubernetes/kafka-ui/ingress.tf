resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "kafka-ui"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
    annotations = {
      "kubernetes.io/ingress.class" : "nginx"
      "external-dns.alpha.kubernetes.io/alias" : "true"
      "external-dns.alpha.kubernetes.io/target" : "dualstack.${var.ingress.target}"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" : "true"
    }
  }

  spec {
    rule {
      host = var.ingress.host
      http {
        path {
          backend {
            service {
              name = kubernetes_service.this.metadata.0.name
              port {
                number = 8080
                # name = "http"
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}
