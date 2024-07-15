resource "kubernetes_manifest" "test-topic" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"
    metadata = {
      name      = "test-topic"
      namespace = kubernetes_manifest.kafka.manifest.metadata.namespace
      labels = {
        "strimzi.io/cluster"           = kubernetes_manifest.kafka.manifest.metadata.name
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      config = {
        # NOTE: 로그를 3일 동안 보존하도록 설정한다. 3일은 주말을 고려한 값이다.
        "retention.ms" = "259200000"
        # NOTE: 세그먼트 파일 롤링 주기가 최대 1일이 되도록 설정한다.
        "segment.ms" = "86400000"
      }
    }
  }
}
