
# resource "kubernetes_manifest" "kibana" {
#   manifest = {
#     apiVersion = "kibana.k8s.elastic.co/v1"
#     kind       = "Kibana"
#     metadata = {
#       name      = "kibana"
#       namespace = local.namespace
#     }
#     spec = {
#       version = "8.4.3"
#       count   = 1
#       elasticsearchRef = {
#         name = local.elasticsearch_name
#       }
#       config = {
#         monitoring = {
#           ui = {
#             ccs = {
#               enabled = false # https://github.com/elastic/kibana/issues/125756#issuecomment-1043259521
#             }
#           }
#         }
#         xpack = {
#           reporting = {
#             roles = {
#               enabled = false
#             }
#           }
#           # See https://www.elastic.co/guide/en/observability/current/apm-server-configuration.html  If you don’t have an internet connection tab
#           fleet = {
#             packages = [
#               {
#                 name    = "apm"
#                 version = "latest"
#               }
#             ]
#           }
#         }
#         server = {
#           #   publicBaseUrl = "https://${var.kibana.ingress_host}"
#         }
#       }
#       # podTemplate       = {
#       #   spec            = {
#       #     containers    = [{
#       #       name        = "kibana"
#       #       resources = {
#       #         requests = {
#       #           cpu = "1"
#       #           memory = "1Gi"
#       #         }
#       #         limits = {
#       #           cpu = "1"
#       #           memory = "1Gi"
#       #         }
#       #       }
#       #     }]
#       #   }
#       # }
#       http = {
#         tls = {
#           selfSignedCertificate = {
#             disabled = true # https://www.elastic.co/guide/en/cloud-on-k8s/2.4/k8s-tls-certificates.html#k8s-disable-tls
#           }
#         }
#       }
#       # https://www.elastic.co/guide/en/cloud-on-k8s/2.4/k8s-stack-monitoring.html
#       monitoring = {
#         metrics = {
#           elasticsearchRefs = [{
#             name      = local.elasticsearch_name
#             namespace = local.namespace
#           }]
#         }
#         logs = {
#           elasticsearchRefs = [{
#             name      = local.elasticsearch_name
#             namespace = local.namespace
#           }]
#         }
#       }
#     }
#   }
# }
