locals {
  cluster_name = "kafka"
  namespace    = "streaming"
}

# 기존의 Role, RoleBinding, ClusterRole, ClusterRoleBinding 및 IAM 정책 리소스들 유지
resource "kubernetes_cluster_role" "kafka_operator" {
  metadata {
    name = "kafka-operator"
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["list", "get"]
  }

  rule {
    api_groups = ["kafka.strimzi.io"]
    resources  = ["*"]
    verbs      = ["list", "get"]
  }
}

resource "kubernetes_cluster_role_binding" "kafka_operator" {
  metadata {
    name = kubernetes_cluster_role.kafka_operator.metadata[0].name
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kafka_operator.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "strimzi-cluster-operator"
    namespace = local.namespace
  }
}

resource "kubernetes_role" "kafka_operator" {
  metadata {
    name      = "kafka-operator-role"
    namespace = local.namespace
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
    # api_groups = ["kafka.strimzi.io"]
    # resources  = ["kafkas", "kafkaconnects", "kafkaconnectors", "kafkatopics"]
    # verbs      = ["create", "get", "list", "watch", "delete", "patch", "update"]
  }
}

resource "kubernetes_role_binding" "kafka_operator" {
  metadata {
    name      = kubernetes_role.kafka_operator.metadata[0].name
    namespace = kubernetes_role.kafka_operator.metadata[0].namespace
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.kafka_operator.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "strimzi-cluster-operator"
    namespace = local.namespace
  }
}

# resource "aws_iam_role_policy_attachment" "kafka_connect_build" {
#   role       = aws_iam_role.kafka_connect_build.name
#   policy_arn = aws_iam_policy.kafka_connect_build.arn
# }

# output "strimzi_kafka_connect_build_iam_role_arn" {
#   value = aws_iam_role.kafka_connect_build.arn
# }

# output "strimzi_kafka_connect_build_output_repository_url" {
#   value = aws_ecr_repository.repository["kafka-connect"].repository_url
# }

// NOTE: https://strimzi.io/blog/2023/09/11/kafka-node-pools-supporting-kraft/ 


resource "kubernetes_manifest" "kafka" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaNodePool"
    metadata = {
      name      = "${local.cluster_name}-broker"
      namespace = local.namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      replicas = 3
      roles    = ["broker", "controller"]
      storage = {
        type = "jbod"
        volumes = [{
          id          = 0
          type        = "persistent-claim"
          size        = "5Gi"
          deleteClaim = false
        }]
      }
    }
  }
}

# # https://github.com/strimzi/strimzi-kafka-operator/blob/f23eb09baa86ac79a3728b8922f35a240fdb77ef/examples/metrics/kafka-metrics.yaml#L69
# resource "kubernetes_config_map" "kafka" {
#   metadata {
#     name      = "kafka-metrics"
#     namespace = local.namespace
#     labels = {
#       "app.kubernetes.io/managed-by" = "terraform"
#     }
#   }

#   data = {
#     "kafka-metrics-config.yml"     = <<EOK
#       # See https://github.com/prometheus/jmx_exporter for more info about JMX Prometheus Exporter metrics
#       lowercaseOutputName: true
#       rules:
#       # Special cases and very specific rules
#       - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value
#         name: kafka_server_$1_$2
#         type: GAUGE
#         labels:
#          clientId: "$3"
#          topic: "$4"
#          partition: "$5"
#       - pattern: kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value
#         name: kafka_server_$1_$2
#         type: GAUGE
#         labels:
#          clientId: "$3"
#          broker: "$4:$5"
#       - pattern: kafka.server<type=(.+), cipher=(.+), protocol=(.+), listener=(.+), networkProcessor=(.+)><>connections
#         name: kafka_server_$1_connections_tls_info
#         type: GAUGE
#         labels:
#           cipher: "$2"
#           protocol: "$3"
#           listener: "$4"
#           networkProcessor: "$5"
#       - pattern: kafka.server<type=(.+), clientSoftwareName=(.+), clientSoftwareVersion=(.+), listener=(.+), networkProcessor=(.+)><>connections
#         name: kafka_server_$1_connections_software
#         type: GAUGE
#         labels:
#           clientSoftwareName: "$2"
#           clientSoftwareVersion: "$3"
#           listener: "$4"
#           networkProcessor: "$5"
#       - pattern: "kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+):"
#         name: kafka_server_$1_$4
#         type: GAUGE
#         labels:
#          listener: "$2"
#          networkProcessor: "$3"
#       - pattern: kafka.server<type=(.+), listener=(.+), networkProcessor=(.+)><>(.+)
#         name: kafka_server_$1_$4
#         type: GAUGE
#         labels:
#          listener: "$2"
#          networkProcessor: "$3"
#       # Some percent metrics use MeanRate attribute
#       # Ex) kafka.server<type=(KafkaRequestHandlerPool), name=(RequestHandlerAvgIdlePercent)><>MeanRate
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>MeanRate
#         name: kafka_$1_$2_$3_percent
#         type: GAUGE
#       # Generic gauges for percents
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*><>Value
#         name: kafka_$1_$2_$3_percent
#         type: GAUGE
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)Percent\w*, (.+)=(.+)><>Value
#         name: kafka_$1_$2_$3_percent
#         type: GAUGE
#         labels:
#           "$4": "$5"
#       # Generic per-second counters with 0-2 key/value pairs
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+), (.+)=(.+)><>Count
#         name: kafka_$1_$2_$3_total
#         type: COUNTER
#         labels:
#           "$4": "$5"
#           "$6": "$7"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*, (.+)=(.+)><>Count
#         name: kafka_$1_$2_$3_total
#         type: COUNTER
#         labels:
#           "$4": "$5"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)PerSec\w*><>Count
#         name: kafka_$1_$2_$3_total
#         type: COUNTER
#       # Generic gauges with 0-2 key/value pairs
#       - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value
#         name: kafka_$1_$2_$3
#         type: GAUGE
#         labels:
#           "$4": "$5"
#           "$6": "$7"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value
#         name: kafka_$1_$2_$3
#         type: GAUGE
#         labels:
#           "$4": "$5"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Value
#         name: kafka_$1_$2_$3
#         type: GAUGE
#       # Emulate Prometheus 'Summary' metrics for the exported 'Histogram's.
#       # Note that these are missing the '_sum' metric!
#       - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count
#         name: kafka_$1_$2_$3_count
#         type: COUNTER
#         labels:
#           "$4": "$5"
#           "$6": "$7"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\d+)thPercentile
#         name: kafka_$1_$2_$3
#         type: GAUGE
#         labels:
#           "$4": "$5"
#           "$6": "$7"
#           quantile: "0.$8"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count
#         name: kafka_$1_$2_$3_count
#         type: COUNTER
#         labels:
#           "$4": "$5"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\d+)thPercentile
#         name: kafka_$1_$2_$3
#         type: GAUGE
#         labels:
#           "$4": "$5"
#           quantile: "0.$6"
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)><>Count
#         name: kafka_$1_$2_$3_count
#         type: COUNTER
#       - pattern: kafka.(\w+)<type=(.+), name=(.+)><>(\d+)thPercentile
#         name: kafka_$1_$2_$3
#         type: GAUGE
#         labels:
#           quantile: "0.$4"
#     EOK
#     "zookeeper-metrics-config.yml" = <<EOZ
#       # See https://github.com/prometheus/jmx_exporter for more info about JMX Prometheus Exporter metrics
#       lowercaseOutputName: true
#       rules:
#       # replicated Zookeeper
#       - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+)><>(\\w+)"
#         name: "zookeeper_$2"
#         type: GAUGE
#       - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+)><>(\\w+)"
#         name: "zookeeper_$3"
#         type: GAUGE
#         labels:
#           replicaId: "$2"
#       - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+)><>(Packets\\w+)"
#         name: "zookeeper_$4"
#         type: COUNTER
#         labels:
#           replicaId: "$2"
#           memberType: "$3"
#       - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+)><>(\\w+)"
#         name: "zookeeper_$4"
#         type: GAUGE
#         labels:
#           replicaId: "$2"
#           memberType: "$3"
#       - pattern: "org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+), name3=(\\w+)><>(\\w+)"
#         name: "zookeeper_$4_$5"
#         type: GAUGE
#         labels:
#           replicaId: "$2"
#           memberType: "$3"
#     EOZ
#     "kafka-connect-metrics-config.yml" = yamlencode({
#       # This config can be empty file.
#       # https://strimzi.io/docs/operators/latest/configuring.html#con-common-configuration-prometheus-reference
#     })
#   }
# }


