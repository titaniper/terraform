provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_manifest" "jenkins-instance" {
  depends_on = [kubernetes_namespace.jenkins]

  manifest = {
    apiVersion = "jenkins.io/v1alpha2"
    kind       = "Jenkins"
    metadata = {
      name      = "jenkins"
      namespace = kubernetes_namespace.jenkins.metadata[0].name
    }

    spec = {
      configurationAsCode = {
        configurations = []
        secret = {
          name = ""
        }
      }

      groovyScripts = {
        configurations = []
        secret = {
          name = ""
        }
      }

      jenkinsAPISettings = {
        authorizationStrategy = "createUser"
      }

      master = {
        disableCSRFProtection = false

        containers = [{
          name            = "jenkins-master"
          image           = "jenkins/jenkins:lts"
          imagePullPolicy = "Always"
          livenessProbe = {
            failureThreshold = 12
            httpGet = {
              path   = "/login"
              port   = "http"
              scheme = "HTTP"
            }
            initialDelaySeconds = 60
            periodSeconds       = 10
            successThreshold    = 1
            timeoutSeconds      = 5
          }
          readinessProbe = {
            failureThreshold = 3
            httpGet = {
              path   = "/login"
              port   = "http"
              scheme = "HTTP"
            }
            initialDelaySeconds = 60
            periodSeconds       = 10
            successThreshold    = 1
            timeoutSeconds      = 1
          }
          resources = {
            limits = {
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }

          env = [
            {
              name  = "JAVA_OPTS"
              value = "-XX:MinRAMPercentage=50.0 -XX:MaxRAMPercentage=80.0 -Djenkins.install.runSetupWizard=false -Djava.awt.headless=true -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Seoul"
            }
          ]
        }]

        basePlugins = [
          {
            name    = "kubernetes"
            version = "1.30.0"
          },
          {
            name    = "workflow-job"
            version = "2.40"
          },
          {
            name    = "workflow-aggregator"
            version = "2.6"
          },
          {
            name    = "git"
            version = "4.8.2"
          },
          {
            name    = "job-dsl"
            version = "1.77"
          },
          {
            name    = "configuration-as-code"
            version = "1.51"
          },
          {
            name    = "kubernetes-credentials-provider"
            version = "0.17"
          },
        ]

        plugins = [
          {
            name    = "docker-workflow"
            version = "1.26"
          },
          {
            name    = "github"
            version = "1.37.1"
          },
          {
            name    = "envinject"
            version = "2.4.0"
          },
          {
            name    = "pipeline-stage-view"
            version = "2.33"
          },
          {
            name    = "blueocean"
            version = "1.27.9"
          },
        ]

      }
    }
  }

  field_manager {
    force_conflicts = true
  }
}

resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins-service"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
  spec {
    selector = {
      app = "jenkins"
    }
    type = "NodePort"
    port {
      port        = 8080
      target_port = 8080
      node_port   = 30000
    }
  }
}
