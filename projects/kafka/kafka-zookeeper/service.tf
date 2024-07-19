resource "kubernetes_service" "kafka-broker-node-port" {
  metadata {
    name      = "kafka-broker-node-port"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/name"       = "kafka-ui"
      "app.kubernetes.io/instance"   = "kafka-broker"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    type = "NodePort"

    # Kafka 브로커의 JMX (Java Management Extensions) 모니터링 도구를 위한 포트.
    port {
      name        = "internal0"
      port        = 9090
      target_port = 9090
      node_port   = 31090 # 사용할 노드 포트를 설정합니다.
    }
    #  클라이언트와 Kafka 브로커 간의 보안 통신을 위해 설정됩니다.  SSL(TLS)을 통한 암호화된 통신.
    port {
      name        = "internal1"
      port        = 9091
      target_port = 9091
      node_port   = 31091 # 사용할 노드 포트를 설정합니다.
    }
    # Kafka 브로커의 기본 포트로 클러스터 내부 통신 및 개발 환경에서 사용됩니다. 기본 PLAINTEXT(비암호화) 통신 포트.
    port {
      name        = "internal2"
      port        = 9092
      target_port = 9092
      node_port   = 31092 # 사용할 노드 포트를 설정합니다.
    }
    # 인증 및 암호화가 필요한 통신에 사용됩니다. (SASL/SSL 또는 다른 보안 프로토콜을 통한 통신.)
    port {
      name        = "internal3"
      port        = 9093
      target_port = 9093
      node_port   = 31093 # 사용할 노드 포트를 설정합니다.
    }
    # 예시: Kubernetes API 서버와의 보안 통신, 웹 애플리케이션의 보안 통신에 사용됩니다 HTTPS(SSL/TLS) 보안 통신 포트.
    port {
      name        = "internal4"
      port        = 8443
      target_port = 8443
      node_port   = 31443 # 사용할 노드 포트를 설정합니다.
    }

    port {
      name        = "external"
      port        = 29092
      target_port = 29092
      node_port   = 32092 # 사용할 노드 포트를 설정합니다.
    }
    selector = {
      "strimzi.io/kind" = "Kafka"
      "strimzi.io/name" = "kafka-kafka"
      "strimzi.io/cluster" = "kafka"
    }
  }
}
