variable "kafka_broker" {
  type        = object({
    host      = string
    filebeat_topic = string
  })
}
