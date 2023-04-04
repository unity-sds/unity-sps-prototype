# Rest API ID from project api gateway deployment, needed to add resources, methods, and integrations to api gateway
data "aws_ssm_parameter" "api_gateway_rest_api_id" {
  name = "/unity/${var.venue}/api-gateway/rest-api-id"
}

# Rest API root resource ID from project api gateway deployment, needed by child resources
data "aws_ssm_parameter" "api_gateway_rest_api_root_resource_id" {
  name = "/unity/${var.venue}/api-gateway/rest-api-root-resource-id"
}

# Lambda authorizer ID in Rest API, needed by methods authorizing with CS custom authorizer
data "aws_ssm_parameter" "api_gateway_rest_api_lambda_authorizer_id" {
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
  authorizer_id = data.aws_ssm_parameter.api_gateway_rest_api_lambda_authorizer_id.value 

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_ades_wpst_proxy_integration" {
  rest_api_id   = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  resource_id   = aws_api_gateway_resource.api_gateway_ades_wpst_proxy_resource.id
  http_method   = aws_api_gateway_method.api_gateway_ades_wpst_proxy_method.http_method
  integration_http_method = "ANY"
  type          = "HTTP_PROXY"
  uri           = "http://${kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname}:${var.service_port_map.ades_wpst_api_service}/{proxy}"
  cache_key_parameters = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }  
}

# Deployment resource, to enable updating a deployment when a dependent resource changes see:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment#triggers
resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_integration.api_gateway_ades_wpst_proxy_integration
  ]
}

resource "null_resource" "api_gateway_stage_update_resource" {
  provisioner "local-exec" {
    command = "aws apigateway update-stage --region ${var.region} --rest-api-id ${data.aws_ssm_parameter.api_gateway_rest_api_id.value} --stage-name=${var.venue} --patch-operations op='replace',path='/deploymentId',value='${aws_api_gateway_deployment.api_gateway_deployment.id}'"
  }
}