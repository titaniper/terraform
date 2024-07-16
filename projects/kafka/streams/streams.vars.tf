variable "docker_image" {
  description = "Docker image name"
  default     = "devjyk/kafka-streams-broadcast"
}

variable "docker_tag" {
  description = "Docker image tag"
  default     = "latest"
}

variable "replicas" {
  description = "Number of replicas for the deployment"
  default     = 1
}

variable "kafka_brokers" {
  description = "Kafka brokers connection string"
  default     = "kafka-kafka-bootstrap.streaming:9092"
}
