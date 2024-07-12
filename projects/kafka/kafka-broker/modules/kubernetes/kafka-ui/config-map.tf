resource "kubernetes_config_map" "this" {
  metadata {
    name      = "${var.name}-fromvalues"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "kafka-ui"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    "config.yml" = yamlencode({
      # auth = {
      #   enabled = false
      #   type = "LOGIN_FORM"
        
      # }
      # auth = {
      #   type = "basic"
      #   enabled = true
      #   basic = {
      #     users = var.users
      #   }
      # }
      # https://github.com/provectus/kafka-ui/wiki/OAuth-Configuration
      auth = {
        type = "OAUTH2"
        oauth2 = {
          client = {
            github = {
              provider = "github"
              clientId = var.oauth.github.client_id
              clientSecret = var.oauth.github.client_secret
              scope = ["read:org"]
              "user-name-attribute" = "login"
              "custom-params" = {
                type = "github"
              }
            }
          }
        }
      }
      # https://github.com/provectus/kafka-ui/wiki/RBAC-(role-based-access-control)
      rbac = {
        roles = [{
          name       = "admin"

          clusters   = var.clusters

          subjects   = [{
            provider = "oauth_github"
            # TODO: https://github.com/provectus/kafka-ui/issues/2751 개발되면 팀별로 권한 지정 가능
            #       현재 user, organization 만 지원 https://provectus.gitbook.io/kafka-ui/configuration/rbac-role-based-access-control#providers
            type     = "organization"
            value    = var.oauth.github.organization
          }]

          permissions = [{
            resource  = "clusterconfig"
            actions   = "all"
          }, {
            resource  = "topic"
            value     = ".*"
            actions   = "all"
          }, {
            resource  = "consumer"
            value     = ".*"
            actions   = "all"
          }, {
            resource  = "schema"
            value     = ".*"
            actions   = "all"
          }, {
            resource  = "connect"
            value     = ".*"
            actions   = "all"
          }, {
            resource  = "ksql"
            actions   = "all"
          }]
        }]
      }

    })
  }
}
