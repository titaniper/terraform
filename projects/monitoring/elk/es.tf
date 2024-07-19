resource "kubernetes_manifest" "elasticsearch" {
  manifest = {
    apiVersion = "elasticsearch.k8s.elastic.co/v1"
    kind       = "Elasticsearch"
    metadata = {
      name      = "elasticsearch"
      namespace = local.namespace
    }
    spec = {
      version = "8.4.3"
      nodeSets = [{
        name  = "master"
        count = 1
        config = {
          node = {
            roles = ["master"]
          }
        }
        podTemplate = {
          spec = {
            containers = [{
              name = "elasticsearch"
            }]
            priorityClassName = "system-cluster-critical"
          }
        }
        volumeClaimTemplates = [{
          metadata = {
            name = "elasticsearch-data"
          }
          spec = {
            storageClassName = "hostpath"
            accessModes      = ["ReadWriteOnce"]
            resources        = { requests = { storage = "1Gi" } }
          }
        }]
        }, {
        name  = "data"
        count = 1
        config = {
          node = {
            roles = ["data", "ingest"]
          }
        }
        podTemplate = {
          spec = {
            containers = [{
              name = "elasticsearch"
              # resources   = {
              #   requests  = {
              #     cpu     = "200m"
              #     memory  = "3Gi"
              #   }
              #   limits    = {
              #     memory  = "3Gi"
              #   }
              # }
            }]
            priorityClassName = "system-cluster-critical"
          }
        }
        volumeClaimTemplates = [{
          metadata = {
            name = "elasticsearch-data"
          }
          spec = {
            storageClassName = "hostpath"
            accessModes      = ["ReadWriteOnce"]
            resources        = { requests = { storage = "1Gi" } }
          }
        }]
      }]
      http = {
        tls = {
          selfSignedCertificate = {
            disabled = true
          }
        }
      }
      monitoring = {
        metrics = {
          elasticsearchRefs = [{
            name      = "elasticsearch"
            namespace = local.namespace
          }]
        }
        logs = {
          elasticsearchRefs = [{
            name      = "elasticsearch"
            namespace = local.namespace
          }]
        }
      }
    }
  }

  field_manager {
    force_conflicts = true
  }
}
