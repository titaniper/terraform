provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  # host        = "https://192.168.49.2:8443"
}

locals {
  namespace    = "streaming"
  cluster_name = "streaming"
}

resource "helm_release" "strimzi_kafka_operator" {
  name       = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  namespace  = local.cluster_name
  version    = "0.37.0"

  set {
    name  = "defaultKafkaVersion"
    value = "3.5.1"
  }
}

output "strimzi_kafka_operator_namespace" {
  value = local.cluster_name
}
