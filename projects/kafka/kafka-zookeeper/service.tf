resource "kubernetes_service" "kafka-broker-node-port" {
  metadata {
    name      = "kafka-broker-node-port"
    namespace = local.namespace
  }

  spec {
    type = "NodePort"

    port {
      name = "internal"
      port        = 9092
      target_port = 9092
      node_port   = 31092 # 사용할 노드 포트를 설정합니다.
    }

    port {
      name = "external"
      port        = 29092
      target_port = 29092
      node_port   = 32092 # 사용할 노드 포트를 설정합니다.
    }

    selector = {
      "strimzi.io/kind" = "Kafka"
    }
  }
}
