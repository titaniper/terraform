provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  namespace = "monitoring"
}

# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = local.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }
      spec {
        container {
          image = "prom/prometheus"
          name  = "prometheus"
          port {
            container_port = 9090
          }
          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus/"
            sub_path   = "prometheus.yml"
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.prometheus_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = local.namespace
  }
  data = {
    "prometheus.yml" = <<YAML
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
YAML
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = local.namespace
  }
  spec {
    selector = {
      app = "prometheus"
    }
    port {
      port        = 9090
      target_port = 9090
    }
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  spec {
    type = "NodePort"
    selector = {
      app = "prometheus"
    }
    port {
      port        = 9090
      target_port = 9090
      node_port   = 30090 # 원하는 NodePort 설정
    }
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = local.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "grafana"
      }
    }
    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }
      spec {
        container {
          image = "grafana/grafana"
          name  = "grafana"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = local.namespace
  }
  spec {
    selector = {
      app = "grafana"
    }
    port {
      port        = 3000
      target_port = 3000
    }
  }
}

resource "kubernetes_service" "grafana-node-port" {
  metadata {
    name      = "grafana-node-port"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  spec {
    type = "NodePort"
    selector = {
      app = "grafana"
    }
    port {
      port        = 3000
      target_port = 3000
      node_port   = 30300 # 원하는 NodePort 설정
    }
  }
}
