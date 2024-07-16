variable "name" {
  type    = string
}

variable "namespace" {
  type    = string
}

variable "operator_version" {
  type    = string
}

variable "kafka_version" {
  type    = string
}

variable "supported_kafka_versions" {
  type    = list(string)
}
