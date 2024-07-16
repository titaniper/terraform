locals {
  namespace = "streaming"
}

resource "kubernetes_secret" "mysql_password" {
  metadata {
    name      = "mysql-password"
    namespace = local.namespace
  }

  data = {
    password = "yourpassword"
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

resource "kubernetes_service" "mysql-node" {
  metadata {
    name      = "mysql-node"
    namespace = local.namespace
  }

  spec {
    type = "NodePort"

    port {
      port        = 3306
      target_port = 3306
      node_port   = 30036  # 사용할 노드 포트를 설정합니다.
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
          # 8.4에서는 에러남 # 8.0에서 문제가 있다. https://groups.google.com/g/debezium/c/l9uFOwUm7XQ/m/By-6FRWlAAAJ 
          image = "mysql:8.1" 

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
