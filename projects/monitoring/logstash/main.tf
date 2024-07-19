provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  name      = "logstash"
  namespace = "monitoring"
}


resource "kubernetes_config_map" "logstash_pipeline" {
  metadata {
    name      = "logstash"
    namespace = local.namespace
  }

  data = {
    "logstash.conf" = <<EOF
input {
  beats {
    port => 5044
  }
}
output {
  elasticsearch {
    hosts => [ "http://elasticsearch-es-data.monitoring.svc.cluster.local:9200" ]
    user => "elastic"
    password => "hk85tdH35c4BmQYq0s934L0E"
  }
}
EOF
  }
}


resource "kubernetes_manifest" "logstash_quickstart" {
  manifest = {
    apiVersion = "logstash.k8s.elastic.co/v1alpha1"
    kind       = "Logstash"
    metadata = {
      name = "quickstart"
      namespace = local.namespace
    }
    spec = {
      count = 1
      elasticsearchRefs = [{
        name        = "quickstart"
        clusterName = "qs"
      }]
      version = "8.14.3"
      pipelines = [{
        pipeline = {
          id = "main"
          config = {
            string = <<EOT
input {
  beats {
    port => 5044
  }
}
output {
  elasticsearch {
    hosts => [ "http://elasticsearch-es-data.monitoring.svc.cluster.local:9200" ]
    user => "elastic"
    password => "hk85tdH35c4BmQYq0s934L0E"
  }
}
EOT
          }
        }
      }]
      services = [{
        name = "beats"
        service = {
          spec = {
            type = "NodePort"
            ports = [{
              port       = 5044
              name       = "filebeat"
              protocol   = "TCP"
              targetPort = 5044
            }]
          }
        }
      }]
    }
  }
}
