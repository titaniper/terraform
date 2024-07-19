resource "kubernetes_manifest" "filebeat" {
  manifest = {
    apiVersion = "beat.k8s.elastic.co/v1beta1"
    kind       = "Beat"
    metadata = {
      name      = "filebeat"
      namespace = local.namespace
    }
    spec = {
      type    = "filebeat"
      version = "8.4.3"
      # elasticsearchRef = {
      #   name  = local.elasticsearch_name
      # }
      config = {
        filebeat = {
          inputs = [{
            type  = "container"
            paths = ["/var/log/containers/*.log"]
            json = {
              keys_under_root       = true
              message_key           = "message"
              overwrite_keys        = true
              expand_keys           = true
              ignore_decoding_error = true
            }
            multiline = {
              type    = "pattern"
              pattern = "^[[:space:]]"
              negate  = false
              match   = "after"
            }
            # https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-input-container.html#filebeat-input-container-close-renamed
            # NOTE: 컨테이너가 삭제되면 로그 파일이 곧바로 삭제되는데, 로그 수집 핸들러또한 바로 닫혀서 로그가 끝까지 수집되지 않을수 있어 끝까지 수집될 수 있게 한다.
            clean_removed = false
            close_removed = false
          }]
        }

        processors = [{
          script = {
            # NOTE: processor 의 javascript는 ES5 문법만 지원하므로 주의.
            lang   = "javascript"
            source = <<EOF
            // NOTE: function 이름은 반드시 process여야 한다.
            function process(event) {
              var body = event.Get("http.request.body.content");
              if (body) {
                var paresdBody = JSON.parse(body);

                event.Put("http.request.body.content", JSON.stringify(paresdBody, function(_, value) {
                  if (value.password) value.password = "[REDACTED]";
                  return value;
                }));
              }
            }
            EOF
          }
        }]
        output = {
          kafka = {
            hosts = [var.kafka_broker.host]
            topic = var.kafka_broker.filebeat_topic
          }
        }
      }
      daemonSet = {
        podTemplate = {
          spec = {
            # dnsPolicy       = "ClusterFirstWithHostNet"
            # hostNetwork     = true
            securityContext = {
              runAsUser = 0
            }
            containers = [{
              name = "filebeat"
              resources = {
                requests = {
                  cpu    = "20m"
                  memory = "200Mi"
                }
                limits = {
                  memory = "200Mi"
                }
              }
              volumeMounts = [{
                name      = "varlogcontainers"
                mountPath = "/var/log/containers"
                }, {
                name      = "varlogpods"
                mountPath = "/var/log/pods"
                # - name: varlibdockercontainers
                #   mountPath: /var/lib/docker/containers
              }]
            }]
            volumes = [{
              name = "varlogcontainers"
              hostPath = {
                path = "/var/log/containers"
              }
              }, {
              name = "varlogpods"
              hostPath = {
                path = "/var/log/pods"
              }
              # - name: varlibdockercontainers
              #   hostPath:
              #     path: /var/lib/docker/containers
            }]
            tolerations = [{
              key    = "node-role.kubernetes.io/master"
              effect = "NoSchedule"
            }]

            priorityClassName = "system-cluster-critical"
          }
        }
      }
    }
  }

  field_manager {
    force_conflicts = true # elastic-operator 도 Filebeat object 를 업데이트 함
  }
}
