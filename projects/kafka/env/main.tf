provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "streaming" {
  metadata {
    name = "streaming"
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

# module "strimzi-kafka-operator" {
#   source                   = "../../../../modules/kubernetes/strimzi-kafka-operator"
#   name                     = "strimzi-kafka-operator"
#   namespace                = kubernetes_namespace.streaming.metadata.0.name
#   operator_version         = "0.37.0"
#   kafka_version            = "3.5.1" # NOTE: operator_version 버전을 바꿀때 kafka_version 도 같이 바꿔야 할 때가 있다. https://github.com/strimzi/strimzi-kafka-operator/releases/tag/0.37.0
#   supported_kafka_versions = ["3.4.0", "3.4.1", "3.5.0", "3.5.1"] # NOTE: kafka_version 버전을 바꿀때 supported_kafka_versions 도 같이 바꿔야 할 때가 있다. https://github.com/strimzi/strimzi-kafka-operator/releases/tag/0.37.0
# }

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
