locals {
  namespace = "streaming"
}

resource "kubernetes_manifest" "kafka-connect" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnect"
    metadata = {
      name      = "${local.namespace}-connect"
      namespace = local.namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
      annotations = {
        "strimzi.io/use-connector-resources" = "true"
      }
    }
    spec = {
      replicas = 3
      # authentication: (4)
      #   type: tls
      #   certificateAndKey:
      #     certificate: source.crt
      #     key: source.key
      #     secretName: my-user-source
      bootstrapServers = "kafka-kafka-bootstrap:9092"
      # tls: (6)
      #   trustedCertificates:
      #     - secretName: my-cluster-cluster-cert
      #       certificate: ca.crt
      #     - secretName: my-cluster-cluster-cert
      #       certificate: ca2.crt
      config = {
        "group.id"                          = "${local.namespace}-connect"
        "offset.storage.topic"              = "${local.namespace}-connect-offsets"
        "config.storage.topic"              = "${local.namespace}-connect-configs"
        "status.storage.topic"              = "${local.namespace}-connect-status"
        "key.converter"                     = "org.apache.kafka.connect.json.JsonConverter"
        "value.converter"                   = "org.apache.kafka.connect.json.JsonConverter"
        "key.converter.schemas.enable"      = true
        "value.converter.schemas.enable"    = true
        "config.storage.replication.factor" = 1
        "offset.storage.replication.factor" = 1
        "status.storage.replication.factor" = 1
        # NOTE: 1024 * 1024 * 20 = 20MB
        "max.request.size"          = 20971520
        "producer.max.request.size" = 20971520 # NOTE: 둘 다 없으면 동작을 안한다... https://github.com/strimzi/strimzi-kafka-operator/issues/2716
        "max.partition.fetch.bytes" = 20971520
        "fetch.max.bytes"           = 20971520
      }
      build = {
        output = {
          type = "docker"
          # type = "docker"
          image      = "devjyk/kafka-connect:latest"
          pushSecret = "docker-credentials"
          #   image = "${data.terraform_remote_state.barrel.outputs.strimzi_kafka_connect_build_output_repository_url}:latest"
          # image = "strimzi/kafka-connect"
          # image = docker_image.kafka_connect.name
        }
        plugins = [{
          name = "debezium-mysql-connector"
          artifacts = [{
            type = "tgz"
            url  = "https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.1.3.Final/debezium-connector-mysql-2.1.3.Final-plugin.tar.gz"
          }]
        }]
      }
      # externalConfiguration = {
      #   env:
      #     - name: AWS_ACCESS_KEY_ID
      #       valueFrom:
      #         secretKeyRef:
      #           name: aws-creds
      #           key: awsAccessKey
      #     - name: AWS_SECRET_ACCESS_KEY
      #       valueFrom:
      #         secretKeyRef:
      #           name: aws-creds
      #           key: awsSecretAccessKey
      # }
      #   resources = {
      #     requests = {
      #       cpu    = "500m"
      #       memory = "2Gi"
      #     }
      #     limits = {
      #       memory = "2Gi"
      #     }
      #   }
      logging = {
        type = "inline"
        loggers = {
          "log4j.rootLogger" = "INFO"
        }
      }
      readinessProbe = {
        initialDelaySeconds = 15
        timeoutSeconds      = 5
      }
      livenessProbe = {
        initialDelaySeconds = 15
        timeoutSeconds      = 5
      }
      #   metricsConfig = {
      #     type = "jmxPrometheusExporter"
      #     valueFrom = {
      #       configMapKeyRef = {
      #         name = kubernetes_config_map.kafka.metadata.0.name
      #         key  = "kafka-connect-metrics-config.yml"
      #       }
      #     }
      #   }
      jvmOptions = {
        "-Xmx" = "1g"
        "-Xms" = "1g"
      }
      # image: my-org/my-image:latest (17)
      # rack = {
      #   "topologyKey" = "topology.kubernetes.io/zone"
      # }
      # template = {
      #   # imagePullSecrets = [{
      #   #   name = password
      #   # }]
      #   # buildPod = {
      #   #   metadata = {
      #   #     # annotations = {
      #   #     #   "iam.amazonaws.com/role" = data.terraform_remote_state.barrel.outputs.strimzi_kafka_connect_build_iam_role_arn
      #   #     # }
      #   #   }
      #   # }
      #   # pod = {
      #   #   affinity = {
      #   #     podAntiAffinity = {
      #   #       requiredDuringSchedulingIgnoredDuringExecution = [{
      #   #         labelSelector = {
      #   #           matchExpressions = [{
      #   #             key      = "app.kubernetes.io/instance"
      #   #             operator = "In"
      #   #             values   = ["kafka-connect"]
      #   #           }]
      #   #         }
      #   #         topologyKey = "kubernetes.io/hostname"
      #   #       }]
      #   #     }
      #   #   }
      #   # }
      #   # connectContainer = {
      #   #   env:
      #   #     - name: JAEGER_SERVICE_NAME
      #   #       value: my-jaeger-service
      #   #     - name: JAEGER_AGENT_HOST
      #   #       value: jaeger-agent-name
      #   #     - name: JAEGER_AGENT_PORT
      #   #       value: "6831"
      #   # }
      # }
    }
  }
}
