# Rest API ID from project api gateway deployment, needed to add resources, methods, and integrations to api gateway
data "aws_ssm_parameter" "api_gateway_rest_api_id" {
  name = "/unity/cs/routing/api-gateway/rest-api-id-2"
}

# Rest API root resource ID from project api gateway deployment, needed by child resources
data "aws_api_gateway_resource" "api_gateway_rest_api_root_resource" {
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  path        = "/"
}

resource "aws_api_gateway_resource" "api_gateway_sps_resource" {
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id.value
  parent_id   = data.aws_api_gateway_resource.api_gateway_rest_api_root_resource.id
  path_part   = "sps"
}

resource "aws_ssm_parameter" "api_gateway_sps_path_resource_id" {
  name  = "/unity/${var.service_area}/api-gateway/sps_resource_id"
  type  = "String"
  value = aws_api_gateway_resource.api_gateway_sps_resource.id
}
