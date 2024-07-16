terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  # host        = "https://192.168.49.2:8443"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
