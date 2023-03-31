# https://github.com/unity-sds/unity-cs-infra/blob/main/terraform-api-gateway-cognito/post-deployment/update-api-gateway-urls.sh
data "aws_ssm_parameter" "api_gateway_rest_api_id" {
  # name = format("/unity/${var.venue}/%s-%s/api-gateway/rest-api-id", var.namespace, var.counter)
  name = "/unity/${var.venue}/api-gateway/rest-api-id"
}

data "aws_ssm_parameter" "api_gateway_rest_api_root_resource_id" {
  # name = format("/unity/${var.venue}/%s-%s/api-gateway/rest-api-id", var.namespace, var.counter)
  name = "/unity/${var.venue}/api-gateway/rest-api-root-resource-id"
}

data "aws_ssm_parameter" "api_gateway_rest_api_lambda_authorizer_id" {
  # name = format("/unity/${var.venue}/%s-%s/api-gateway/rest-api-id", var.namespace, var.counter)
  name = "/unity/${var.venue}/api-gateway/rest-api-lambda-authorizer-id"
}

resource "aws_api_gateway_resource" "api_gateway_ades_wpst_resource" {
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  parent_id   = data.aws_ssm_parameter.api_gateway_rest_api_root_resource_id.value
  path_part   = "ades-wpst"
}

resource "aws_api_gateway_resource" "api_gateway_ades_wpst_proxy_resource" {
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  parent_id   = aws_api_gateway_resource.api_gateway_ades_wpst_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_gateway_ades_wpst_proxy_method" {
  rest_api_id   = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  resource_id   = aws_api_gateway_resource.api_gateway_ades_wpst_proxy_resource.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = data.aws_ssm_parameter.api_gateway_rest_api_root_resource_id.value 

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_ades_wpst_proxy_integration" {
  rest_api_id   = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  resource_id   = aws_api_gateway_resource.api_gateway_ades_wpst_proxy_resource.id
  http_method   = aws_api_gateway_method.api_gateway_ades_wpst_proxy_method.http_method
  type          = "HTTP_PROXY"
  uri           = "${kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname[0]}:${var.service_port_map.ades_wpst_api_service}"
}