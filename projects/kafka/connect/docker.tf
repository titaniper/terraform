locals {
  dockerconfig = {
    auths = {
      "https://index.docker.io/v1/" = {
        username = var.docker_username
        password = var.docker_password
        email    = "karjyk@gmail.com"
        auth     = base64encode("${var.docker_username}:${var.docker_password}")
      }
    }
  }
}

resource "kubernetes_secret" "docker_credentials" {
  metadata {
    name      = "docker-credentials"
    namespace = local.namespace
  }
  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfig)
  }
}