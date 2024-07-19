resource "kubernetes_manifest" "elasticsearch" {
  manifest = {
    apiVersion = "elasticsearch.k8s.elastic.co/v1"
    kind       = "Elasticsearch"
    metadata = {
      name      = "elasticsearch"
      namespace = local.namespace
      annotations = {
        "eck.k8s.elastic.co/downward-node-labels" = "topology.kubernetes.io/zone"
      }
    }
    spec = {
      version = "8.4.3"
      nodeSets = [{
        name  = "master"
        count = 1
        config = {
          node = {
            roles = ["master"]
            attr  = { zone = "$${ZONE}" }
          }
          cluster = { routing = { allocation = { awareness = { attributes = "k8s_node_name,zone" } } } }
        }
        podTemplate = {
          spec = {
            containers = [{
              name = "elasticsearch"
              env = [{
                name      = "ZONE"
                valueFrom = { fieldRef = { fieldPath = "metadata.annotations['topology.kubernetes.io/zone']" } }
              }]
            }]
            priorityClassName = "system-cluster-critical"
            topologySpreadConstraints = [{
              maxSkew           = 1
              topologyKey       = "topology.kubernetes.io/zone"
              whenUnsatisfiable = "DoNotSchedule"
              labelSelector = {
                matchLabels = {
                  "elasticsearch.k8s.elastic.co/cluster-name"     = "elasticsearch"
                  "elasticsearch.k8s.elastic.co/statefulset-name" = "elasticsearch-es-master"
                }
              }
            }]
          }
        }
        volumeClaimTemplates = [{
          metadata = {
            name = "elasticsearch-data" # Do not change this name unless you set up a volume mount for the data path.
          }
          spec = {
            storageClassName = "hostpath"
            accessModes      = ["ReadWriteOnce"]
            resources        = { requests = { storage = "1Gi" } }
          }
        }]
      }, {
        name    = "data"
        count   = 3
        config  = {
          node  = {
            roles = ["data_content", "data_hot", "data_warm", "ingest"]
            attr  = { zone = "$${ZONE}" }
          }
          cluster = { routing = { allocation = { awareness = { attributes = "k8s_node_name,zone" } } } }
        }
        podTemplate       = {
          spec            = {
            containers    = [{
              name        = "elasticsearch"
              env         = [{
                name      = "ZONE"
                valueFrom = { fieldRef = { fieldPath = "metadata.annotations['topology.kubernetes.io/zone']" } }

              }]
              resources   = {
                // NOTE: 계속 모니터링하고 조정 필요
                requests  = {
                  cpu     = "200m"
                  memory  = "3Gi"
                }
                limits    = {
                  memory  = "3Gi"
                }
              }
            }]
            priorityClassName = "system-cluster-critical"
            topologySpreadConstraints = [{
              maxSkew           = 1
              topologyKey       = "topology.kubernetes.io/zone"
              whenUnsatisfiable = "DoNotSchedule"
              labelSelector     = {
                matchLabels     = {
                  "elasticsearch.k8s.elastic.co/cluster-name"     = "elasticsearch"
                  "elasticsearch.k8s.elastic.co/statefulset-name" = "elasticsearch-es-master"
                }
              }
            }]
          }
        }
        volumeClaimTemplates = [{
          metadata = {
            name   = "elasticsearch-data" # Do not change this name unless you set up a volume mount for the data path.
          }
          spec  = {
            storageClassName = "hostpath"
            accessModes      = ["ReadWriteOnce"]
            resources        = { requests = { storage = "1Gi" } }
          }
        }]
      }]
      http = {
        tls = {
          selfSignedCertificate = {
            disabled = true # https://www.elastic.co/guide/en/cloud-on-k8s/2.4/k8s-tls-certificates.html#k8s-disable-tls
          }
        }
      }
      # https://www.elastic.co/guide/en/cloud-on-k8s/2.4/k8s-stack-monitoring.html
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

  // for operator
  field_manager {
    force_conflicts = true
  }
}
