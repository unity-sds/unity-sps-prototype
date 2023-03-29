# https://github.com/unity-sds/unity-cs-infra/blob/main/terraform-api-gateway-cognito/post-deployment/update-api-gateway-urls.sh
data "aws_ssm_parameter" "api_gateway_rest_api_id" {
  # name = format("/unity/${var.venue}/%s-%s/api-gateway/rest-api-id", var.namespace, var.counter)
  name = "/unity/${var.venue}/api-gateway/rest-api-id"
}

# API spec template populated with domains through url
data "template_file" "api_template"{
  template = "${file(var.open_api_spec_file)}"

  vars = {
    adesWpstUri = "${kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname[0]}:${var.service_port_map.ades_wpst_api_service}",
    grqEsUri = "${kubernetes_service.grq-es.status[0].load_balancer[0].ingress[0].hostname[0]}:${var.service_port_map.grq2_es}",
    grqRestApiUri = "-",
    hysdsUiiUri = "-",
    mozartEsUri = "${kubernetes_service.mozart-es.status[0].load_balancer[0].ingress[0].hostname[0]}:${var.service_port_map.mozart_es}",
    mozartRestApiUri = "-"
  }
}

# Breakout region into a variable
resource "null_resource" "update_api_gateway_stage_variables" {
  provisioner "local-exec" {
    command = <<-EOT
      aws apigateway put-rest-api --rest-api-id ${data.aws_ssm_parameter.api_gateway_rest_api_id} --body "${data.template_file.api_template.rendered}" --mode merge --region ${var.region} --cli-binary-format raw-in-base64-out
    EOT
  }
}
