provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  namespace = "monitoring"
}

resource "kubernetes_secret" "alertmanager-config" {
  metadata {
    name      = "alertmanager-config"
    namespace = local.namespace
  }

  data = {
    discord_url = var.discord_url
  }
}

resource "kubernetes_manifest" "alertmanager-config" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "AlertmanagerConfig"

    metadata = {
      name      = "default"
      namespace = local.namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }

    spec = {
      route = {
        groupBy        = ["alertname"]
        groupInterval  = "15m"
        repeatInterval = "15m"
        receiver       = "default"
        routes = [{
          receiver = "technical-support"
          matchers = [{
            name  = "service"
            value = "ben"
          }]
          groupInterval       = "5m"
          repeatInterval      = "1d"
          activeTimeIntervals = ["weekdays"]
        }]
      }

      receivers = [{
        name = "default"
        discordConfigs = [{
          sendResolved = true
          apiURL = {
            name = kubernetes_secret.alertmanager-config.metadata[0].name
            key  = "discord_url"
          }
          title = "(${var.env}) [{{ .Status | toUpper }}{{ if eq .Status \"firing\" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}"
          text  = <<-MSG
            {{ range .Alerts -}}
            {{ .Annotations.description }}
            {{ end }}
            MSG
        }]
        }, {
        name = "technical-support"
        discordConfigs = [{
          sendResolved = false
          apiURL = {
            name = kubernetes_secret.alertmanager-config.metadata[0].name
            key  = "discord_url"
          }
          title   = "(${var.env}) [{{ .Status | toUpper }}{{ if eq .Status \"firing\" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ .CommonLabels.alertname }}"
          message = <<-MSG
            {{ range .Alerts -}}
            {{ .Annotations.description }}
            {{ end }}
            MSG
        }]
      }]

      muteTimeIntervals = [{
        name = "weekdays"
        timeIntervals = [{
          weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
          location = "Asia/Seoul"
        }]
      }]
    }
  }
}

// NOTE: 분리할 수 있다.
resource "kubernetes_manifest" "service-api" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "service-api"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
      }
    }
    spec = {
      namespaceSelector = {
        matchNames = ["service"]
      }
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "service-api"
        }
      }
      endpoints = [{
        path     = "/metrics"
        port     = "metrics"
        interval = "1h"
      }]
    }
  }
}

// NOTE: https://github.com/prometheus-operator/prometheus-operator/blob/main/example/prometheus-operator-crd-full/monitoring.coreos.com_scrapeconfigs.yaml
// NOTE: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/scrapeconfig.md
# ScrapeConfig 리소스 생성
resource "kubernetes_manifest" "external_metrics_scrapeconfig" {
  # depends_on = [helm_release.prometheus_operator]

  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "ScrapeConfig"
    metadata = {
      name      = "external-metrics-scrapeconfig"
      namespace = "monitoring"
    }
    spec = {
      jobName        = "external-metrics"
      scrapeInterval = "5s"
      staticConfigs = [{
        name    = "test"
        targets = ["external-metrics-endpoint:9090"]
      }]
    }
  }
}

