variable "elasticsearch" {
  description = "Elasticsearch configuration"
  type = object({
    api_key   = string
    endpoints = list(string)
  })
}

variable "kibana" {
  description = "Kibana configuration"
  type = object({
    api_key      = string
    ingress_host = string
  })
}
