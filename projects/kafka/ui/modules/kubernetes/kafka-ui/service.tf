resource "kubernetes_service" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "kafka-ui"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    port {
      port        = 80
      target_port = 8080 # 8080으로 수정합니다.
      protocol    = "TCP"
      name        = "http"
    }

    selector = {
      "app.kubernetes.io/name"     = "kafka-ui"
      "app.kubernetes.io/instance" = var.name
    }
  }
}

# NodePort 서비스
resource "kubernetes_service" "this-node-port" {
  metadata {
    name      = "${var.name}-node-port"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "kafka-ui"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    type = "NodePort"
    port {
      target_port = 8080 # 8080으로 수정합니다.
      protocol    = "TCP"
      name        = "http"
      port        = 8080
      node_port   = var.service.node_port
    }

    selector = {
      "app.kubernetes.io/name"     = "kafka-ui"
      "app.kubernetes.io/instance" = var.name
    }
  }
}

resource "kubernetes_service" "this-node-port2" {
  metadata {
    name      = "${var.name}-node-port2"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "kafka-ui"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    type = "NodePort"
    port {
      # 클러스터 내부
      port        = 8080
      # 컨테이너 포트
      target_port = 8080
      # 노드 상에서 포트
      node_port   = 31101
      protocol    = "TCP"
      name        = "http"
    }

    selector = {
      "app.kubernetes.io/name"     = "kafka-ui"
      "app.kubernetes.io/instance" = var.name
    }
  }
}


output "kafka_ui_url" {
  value = "http://localhost:${var.service.node_port}"
}
