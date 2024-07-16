# resource "kubernetes_manifest" "kafka_connect" {
#   manifest = {
#     apiVersion = "kafka.strimzi.io/v1beta2"
#     kind       = "KafkaConnect"
#     metadata = {
#       name      = "debezium-mysql-connect-cluster"
#       namespace = "streaming" # 실제 네임스페이스로 변경하세요
#     }
#     spec = {
#       version          = "3.5.0" # Kafka 버전을 지정하세요
#       replicas         = 1
#       bootstrapServers = "kafka-kafka-bootstrap:9092" # 실제 Kafka 부트스트랩 서버 주소로 변경하세요

#       image = "debezium/connect:2.3" # Debezium Kafka Connect 이미지

#       config = {
#         "group.id"                       = "debezium-mysql-connect-cluster"
#         "offset.storage.topic"           = "connect-offsets"
#         "config.storage.topic"           = "connect-configs"
#         "status.storage.topic"           = "connect-status"
#         "key.converter"                  = "org.apache.kafka.connect.json.JsonConverter"
#         "value.converter"                = "org.apache.kafka.connect.json.JsonConverter"
#         "key.converter.schemas.enable"   = "true"
#         "value.converter.schemas.enable" = "true"
#       }
#     }
#   }
# }
