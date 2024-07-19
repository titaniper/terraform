resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "nginx-logs"
            mount_path = "/var/log/nginx"
          }
        }
        volume {
          name = "nginx-logs"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}
