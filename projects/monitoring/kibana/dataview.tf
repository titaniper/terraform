# resource "elasticstack_kibana_data_view" "logs" {
#   data_view = {
#     name            = "logs-*"
#     title           = "logs-*"
#     time_field_name = "@timestamp"
#   }
#   override = true

#   lifecycle {
#     ignore_changes = [data_view.field_attrs]
#   }
# }
