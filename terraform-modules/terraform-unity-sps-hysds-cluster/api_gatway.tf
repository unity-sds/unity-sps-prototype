# resource "null_resource" "update_api_gateway_stage" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       aws apigateway update-stage --rest-api-id 1gp9st60gd \
#       --stage-name "dev" \
#       --patch-operations op=replace,path=/variables/hysdsUiUrl,value=${kubernetes_service.hysds-ui-service.status[0].load_balancer[0].ingress[0].hostname}:3000
#     EOT
#   }
# }
