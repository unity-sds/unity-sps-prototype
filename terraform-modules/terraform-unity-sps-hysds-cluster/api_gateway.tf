# https://github.com/unity-sds/unity-cs-infra/blob/main/terraform-api-gateway-cognito/post-deployment/update-api-gateway-urls.sh
data "aws_ssm_parameter" "api_gateway_rest_api_id" {
  # name = format("/unity/dev/%s-%s/api-gateway/rest-api-id", var.namespace, var.counter)
  name = "/unity/dev/unity-sps-1/api-gateway/rest-api-id"
}

resource "null_resource" "update_api_gateway_stage_variables" {
  provisioner "local-exec" {
    command = <<-EOT
      aws apigateway update-stage --rest-api-id "${data.aws_ssm_parameter.api_gateway_rest_api_id.value}" --stage-name "test" --region ${var.region} --patch-operations op=replace,path=/variables/adesWpstUrl,value="${kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname}"
      aws apigateway update-stage --rest-api-id "${data.aws_ssm_parameter.api_gateway_rest_api_id.value}" --stage-name "test" --region ${var.region} --patch-operations op=replace,path=/variables/grqEsUrl,value="${data.kubernetes_service.grq-es.status[0].load_balancer[0].ingress[0].hostname}"
      aws apigateway update-stage --rest-api-id "${data.aws_ssm_parameter.api_gateway_rest_api_id.value}" --stage-name "test" --region ${var.region} --patch-operations op=replace,path=/variables/grqRestApiUrl,value="-"
      aws apigateway update-stage --rest-api-id "${data.aws_ssm_parameter.api_gateway_rest_api_id.value}" --stage-name "test" --region ${var.region} --patch-operations op=replace,path=/variables/hysdsUiUrl,value="-"
      aws apigateway update-stage --rest-api-id "${data.aws_ssm_parameter.api_gateway_rest_api_id.value}" --stage-name "test" --region ${var.region} --patch-operations op=replace,path=/variables/mozartEsUrl,value="${data.kubernetes_service.mozart-es.status[0].load_balancer[0].ingress[0].hostname}"
      aws apigateway update-stage --rest-api-id "${data.aws_ssm_parameter.api_gateway_rest_api_id.value}" --stage-name "test" --region ${var.region} --patch-operations op=replace,path=/variables/mozartRestApiUrl,value="-"
    EOT
  }
}
