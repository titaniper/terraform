
resource "kubernetes_manifest" "debezium-mysql-connector" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnector"
    metadata = {
      name      = "debezium-mysql-connector"
      namespace = local.namespace
      labels = {
        "strimzi.io/cluster"           = kubernetes_manifest.kafka-connect.manifest.metadata.name
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      class    = "io.debezium.connector.mysql.MySqlConnector"
      tasksMax = 1
      config = {
        # https://debezium.io/documentation/reference/2.1/connectors/mysql.html#mysql-connector-properties
        "database.hostname"                               = "mysql.streaming.svc.cluster.local"
        "database.port"                                   = 3306
        "database.user"                                   = "root"
        "database.password"                               = var.debezium_mysql_password
        # mysql 8.0이상에서 공개 키 검색이 비활성화 되어 있으며 명시적으로 추가
        # "database.allowPublicKeyRetrieval"                = "true" # 추가된 설정
        "topic.prefix"                                    = "debezium"
        "database.server.id"                              = 898411419 # just random int
        "database.include.list"                           = "ben,jerry"
        "table.include.list"                              = "ben.ddd_event,jerry.ddd_event"
        "include.schema.changes"                          = false
        "schema.history.internal.kafka.topic"             = "schemahistory"
        "schema.history.internal.kafka.bootstrap.servers" = "kafka-kafka-bootstrap:9092"

        # NOTE: blob값이 base64 인코딩 되지 않도록 설정 Valid Values: base64, bytes, hex
        "binary.handling.mode" = "bytes"

        # NOTE: 우리는 broker auto.create.topics.enable=false 로 사용하기 때문에 아래 3개의 값 설정이 필요하다
        "topic.creation.enable"                     = "true"
        "topic.creation.default.replication.factor" = "1"
        "topic.creation.default.partitions"         = "1"

        "snapshot.mode"         = "schema_only"
        "snapshot.locking.mode" = "none"

        "message.max.bytes"       = "10485760" # 10MB
        "replica.fetch.max.bytes" = "10485760"

        "retention.ms" = "259200000" # 3 days. 평일에는 장애를 바로 대응해야 하고 주말에 장애가 발생하면 조금 지연될 수 있으니 3일로 설정
        "segment.ms"   = "259200000"
      }
    }
  }
}


resource "kubernetes_manifest" "debezium-mysql-connector2" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaConnector"
    metadata = {
      name      = "debezium-mysql-connector2"
      namespace = local.namespace
      labels = {
        "strimzi.io/cluster"           = kubernetes_manifest.kafka-connect.manifest.metadata.name
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      class    = "io.debezium.connector.mysql.MySqlConnector"
      tasksMax = 1
      config = {
        # https://debezium.io/documentation/reference/2.1/connectors/mysql.html#mysql-connector-properties
        "database.hostname"                               = "mysql.streaming.svc.cluster.local"
        "database.port"                                   = 3306
        "database.user"                                   = "root"
        "database.password"                               = var.debezium_mysql_password
        # mysql 8.0이상에서 공개 키 검색이 비활성화 되어 있으며 명시적으로 추가
        # "database.allowPublicKeyRetrieval"                = "true" # 추가된 설정
        "topic.prefix"                                    = "debezium2"
        "database.server.id"                              = 898411419 # just random int
        "database.include.list"                           = "ben,jerry"
        "table.include.list"                              = "ben.ddd_event,jerry.ddd_event"
        "include.schema.changes"                          = false
        "schema.history.internal.kafka.topic"             = "schemahistory2"
        "schema.history.internal.kafka.bootstrap.servers" = "kafka-kafka-bootstrap:9092"

        # NOTE: blob값이 base64 인코딩 되지 않도록 설정 Valid Values: base64, bytes, hex
        "binary.handling.mode" = "bytes"

        # NOTE: 우리는 broker auto.create.topics.enable=false 로 사용하기 때문에 아래 3개의 값 설정이 필요하다
        "topic.creation.enable"                     = "true"
        "topic.creation.default.replication.factor" = "1"
        "topic.creation.default.partitions"         = "1"

        "snapshot.mode"         = "schema_only"
        "snapshot.locking.mode" = "none"

        "message.max.bytes"       = "10485760" # 10MB
        "replica.fetch.max.bytes" = "10485760"

        "retention.ms" = "259200000" # 3 days. 평일에는 장애를 바로 대응해야 하고 주말에 장애가 발생하면 조금 지연될 수 있으니 3일로 설정
        "segment.ms"   = "259200000"
        "transforms"   = "filter"
        "transforms.filter.type" = "io.debezium.transforms.Filter"
        "transforms.filter.language" = "jsr223.groovy"
        "transforms.filter.condition" = "value.op == 'c'"
      }
    }
  }
}
