locals {
  namespace = "streaming"
}

resource "kubernetes_secret" "mysql_password" {
  metadata {
    name      = "mysql-password"
    namespace = local.namespace
  }

  data = {
    password = "yourpassword" # root 패스워드를 설정합니다.
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name      = "mysql"
    namespace = local.namespace
  }

  spec {
    port {
      port        = 3306
      target_port = 3306
    }

    selector = {
      app = "mysql"
    }
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = local.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8"

          port {
            container_port = 3306
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql_password.metadata[0].name
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}
