variable "name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "users" {
  description = "List of users for basic authentication"
  type = list(object({
    username = string
    password = string
  }))
}

variable "clusters" {
  type = list(string)
}

variable "ingress" {
  type = object({
    host   = string
    target = string
  })
}

variable "service" {
  type = object({
    node_port = number
  })
}

variable "oauth" {
  type = object({
    github = object({
      client_id     = string
      client_secret = string
      organization  = string
    })
  })
}
