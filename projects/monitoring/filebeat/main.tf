resource "kubernetes_manifest" "filebeat" {
  manifest = {
    apiVersion = "beat.k8s.elastic.co/v1beta1"
    kind       = "Beat"
    metadata = {
      name      = "filebeat"
      namespace = kubernetes_namespace.logging.metadata[0].name
    }
    spec = {
      type    = "filebeat"
      version = "7.14.0"
      elasticsearchRef = {
        name = "elasticsearch"
      }
      config = {
        filebeat.inputs = [{
          type     = "container"
          paths    = ["/var/log/nginx/*.log"]
          symlinks = true
        }]
        output.elasticsearch = {
          hosts = ["http://:9200"]
        }
      }
      daemonSet = {
        podTemplate = {
          spec = {
            serviceAccountName = "filebeat"
            containers = [{
              name = "filebeat"
              securityContext = {
                runAsUser  = 0
                runAsGroup = 0
              }
              volumeMounts = [{
                name      = "varlog"
                mountPath = "/var/log/nginx"
              }]
            }]
            volumes = [{
              name = "varlog"
              hostPath = {
                path = "/var/log/nginx"
              }
            }]
          }
        }
      }
    }
  }
}
