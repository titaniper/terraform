# Source: https://github.com/strimzi/strimzi-kafka-operator/blob/0.37.0/helm-charts/helm3/strimzi-kafka-operator/templates/050-ConfigMap-strimzi-cluster-operator.yaml

resource "kubernetes_config_map" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_service_account.this.metadata.0.namespace
    labels    = {
      "app.kubernetes.io/name"       = "strimzi-kafka-operator"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/version"    = var.operator_version
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    "log4j2.properties" = <<EOP
      name = COConfig
      monitorInterval = 30

      appender.console.type = Console
      appender.console.name = STDOUT
      appender.console.layout.type = PatternLayout
      appender.console.layout.pattern = %d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

      rootLogger.level = $${env:STRIMZI_LOG_LEVEL:-INFO}
      rootLogger.appenderRefs = stdout
      rootLogger.appenderRef.console.ref = STDOUT

      # Kafka AdminClient logging is a bit noisy at INFO level
      logger.kafka.name = org.apache.kafka
      logger.kafka.level = WARN

      # Zookeeper is very verbose even on INFO level -> We set it to WARN by default
      logger.zookeepertrustmanager.name = org.apache.zookeeper
      logger.zookeepertrustmanager.level = WARN

      # Keeps separate level for Netty logging -> to not be changed by the root logger
      logger.netty.name = io.netty
      logger.netty.level = INFO

      # Keeps separate log level for OkHttp client
      logger.okhttp3.name = okhttp3
      logger.okhttp3.level = INFO
    EOP
  }
}
