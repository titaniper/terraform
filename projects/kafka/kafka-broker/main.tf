
provider "kubernetes" {
  config_path = "~/.kube/config"
  # host        = "https://192.168.49.2:8443"
}

resource "kubernetes_namespace" "streaming" {
  metadata {
    name = "streaming"
  }
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
    namespace = kubernetes_namespace.streaming.metadata[0].name
  }
}

resource "kubernetes_role" "kafka_operator" {
  metadata {
    name      = "kafka-operator-role"
    namespace = kubernetes_namespace.streaming.metadata[0].name
  }

  rule {
    api_groups = ["kafka.strimzi.io"]
    resources  = ["kafkas", "kafkaconnects", "kafkaconnectors", "kafkatopics"]
    verbs      = ["create", "get", "list", "watch", "delete", "patch", "update"]
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
    namespace = kubernetes_namespace.streaming.metadata[0].name
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

resource "kubernetes_manifest" "kafka" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = kubernetes_namespace.streaming.metadata[0].name
      namespace = kubernetes_namespace.streaming.metadata[0].name
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      kafka = {
        version  = "3.5.1"
        replicas = 3
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
            configuration = {
              useServiceDnsDomain = true
            }
          },
          {
            name = "tls"
            port = 9093
            type = "internal"
            tls  = true
          }
        ]
        config = {
          "auto.create.topics.enable"                = false
          "offsets.topic.replication.factor"         = 3
          "transaction.state.log.replication.factor" = 3
          "transaction.state.log.min.isr"            = 2
          "default.replication.factor"               = 3
          "min.insync.replicas"                      = 2
          "message.max.bytes"                        = 20971520
          "fetch.max.bytes"                          = 20971520
          "replica.fetch.max.bytes"                  = 20971520
          "replica.fetch.response.max.bytes"         = 20971520
          "max.partition.fetch.bytes"                = 20971520
        }
        storage = {
          type = "jbod"
          volumes = [{
            id          = 0
            type        = "persistent-claim"
            size        = "40Gi"
            deleteClaim = false
          }]
        }
        # metricsConfig = {
        #   type = "jmxPrometheusExporter"
        #   valueFrom = {
        #     configMapKeyRef = {
        #       name = kubernetes_config_map.kafka.metadata.0.name
        #       key  = "kafka-metrics-config.yml"
        #     }
        #   }
        # }
        template = {
          pod = {
            priorityClassName = "system-cluster-critical"
          }
        }
        resources = {
          requests = {
            memory = "3Gi"
          }
          limits = {
            memory = "3Gi"
          }
        }
      }

      zookeeper = {
        replicas = 3
        storage = {
          type        = "persistent-claim"
          size        = "10Gi"
          deleteClaim = false
        }
        # metricsConfig = {
        #   type = "jmxPrometheusExporter"
        #   valueFrom = {
        #     configMapKeyRef = {
        #       name = kubernetes_config_map.kafka.metadata.0.name
        #       key  = "zookeeper-metrics-config.yml"
        #     }
        #   }
        # }
        template = {
          pod = {
            priorityClassName = "system-cluster-critical"
          }
        }
        resources = {
          requests = {
            memory = "512Mi"
          }
          limits = {
            memory = "512Mi"
          }
        }
      }

      entityOperator = {
        topicOperator = {
          resources = {
            requests = {
              memory = "500Mi"
            }
            limits = {
              memory = "500Mi"
            }
          }
        }
        userOperator = {
          resources = {
            requests = {
              memory = "400Mi"
            }
            limits = {
              memory = "400Mi"
            }
          }
        }
      }
      kafkaExporter = {
        topicRegex = ".*"
        groupRegex = ".*"
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

