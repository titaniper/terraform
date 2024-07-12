variable "kafka_ui" {
  type = object({
    ingress = object({
      host   = string
      target = string
    })
    oauth = object({
      github = object({
        client_id     = string
        client_secret = string
      })
    })
    users = list(object({
      username = string
      password = string
    }))
  })
}
