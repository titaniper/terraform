resource "kubernetes_manifest" "kibana" {
  manifest = {
    apiVersion = "kibana.k8s.elastic.co/v1"
    kind       = "Kibana"
    metadata = {
      name      = "kibana"
      namespace = local.namespace
    }
    spec = {
      version = "8.4.3" # Elasticsearch 버전과 일치시키세요
      count   = 1
      elasticsearchRef = {
        name = local.elasticsearch_name
      }
      config = {
        monitoring = {
          ui = {
            ccs = {
              enabled = false # https://github.com/elastic/kibana/issues/125756#issuecomment-1043259521
            }
          }
        }
      }
      http = {
        tls = {
          selfSignedCertificate = {
            disabled = true
          }
        }
      }
      podTemplate = {
        spec = {
          containers = [
            {
              name = "kibana"
              resources = {
                limits = {
                  cpu    = "1"
                  memory = "1Gi"
                }
                requests = {
                  cpu    = "500m"
                  memory = "1Gi"
                }
              }
            }
          ]
        }
      }
    }
  }

  computed_fields = ["metadata.labels", "metadata.annotations","spec.finalizers","status"]

  field_manager {
    force_conflicts = true
  }
}

resource "kubernetes_service" "kibana_nodeport" {
  metadata {
    name      = "kibana-nodeport"
    namespace = local.namespace
  }
  spec {
    selector = {
      "kibana.k8s.elastic.co/name" = "kibana"
    }
    port {
      port        = 5601
      target_port = 5601
      node_port   = 30601
    }
    type = "NodePort"
  }
}