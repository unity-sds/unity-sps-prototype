# Rest API ID from project api gateway deployment, needed to add resources, methods, and integrations to api gateway
data "aws_ssm_parameter" "api_gateway_rest_api_id" {
  count = var.add_routes_to_api_gateway ? 1 : 0
  name  = "/unity/cs/routing/api-gateway/rest-api-id-2"
}

# Rest API root resource ID from project api gateway deployment, needed by child resources
data "aws_ssm_parameter" "api_gateway_rest_api_root_resource_id" {
  count = var.add_routes_to_api_gateway ? 1 : 0
  name  = "/unity/${var.service_area}/api-gateway/sps_resource_id"
}

# Lambda authorizer ID in Rest API, needed by methods authorizing with CS custom authorizer
data "aws_ssm_parameter" "api_gateway_rest_api_lambda_authorizer_id" {
  count = var.add_routes_to_api_gateway ? 1 : 0
  name  = "/unity/${var.venue}/api-gateway/rest-api-lambda-authorizer-id"
}

resource "aws_api_gateway_resource" "deployment_name_resource" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  parent_id   = data.aws_ssm_parameter.api_gateway_rest_api_root_resource_id[0].value
  path_part   = var.deployment_name
}

resource "aws_api_gateway_resource" "api_gateway_ades_wpst_resource" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  parent_id   = aws_api_gateway_resource.deployment_name_resource[0].id
  path_part   = "ades-wpst"
}

resource "aws_api_gateway_resource" "api_gateway_ades_wpst_proxy_resource" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  parent_id   = aws_api_gateway_resource.api_gateway_ades_wpst_resource[0].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_gateway_ades_wpst_proxy_method" {
  count         = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id   = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  resource_id   = aws_api_gateway_resource.api_gateway_ades_wpst_proxy_resource[0].id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = data.aws_ssm_parameter.api_gateway_rest_api_lambda_authorizer_id[0].value

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_ades_wpst_proxy_integration" {
  count                   = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id             = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  resource_id             = aws_api_gateway_resource.api_gateway_ades_wpst_proxy_resource[0].id
  http_method             = aws_api_gateway_method.api_gateway_ades_wpst_proxy_method[0].http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.ades-wpst-load-balancer.dns_name}:${var.service_port_map.ades_wpst_api_service}/{proxy}"
  cache_key_parameters    = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "api_gateway_sps_api_resource" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  parent_id   = aws_api_gateway_resource.deployment_name_resource[0].id
  path_part   = "sps-api"
}

resource "aws_api_gateway_resource" "api_gateway_sps_api_proxy_resource" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  parent_id   = aws_api_gateway_resource.api_gateway_sps_api_resource[0].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_gateway_sps_api_proxy_method" {
  count         = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id   = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  resource_id   = aws_api_gateway_resource.api_gateway_sps_api_proxy_resource[0].id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = data.aws_ssm_parameter.api_gateway_rest_api_lambda_authorizer_id[0].value

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_sps_api_proxy_integration" {
  count                   = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id             = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  resource_id             = aws_api_gateway_resource.api_gateway_sps_api_proxy_resource[0].id
  http_method             = aws_api_gateway_method.api_gateway_sps_api_proxy_method[0].http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.sps-api-load-balancer.dns_name}:${var.service_port_map.sps_api_service}/{proxy}"
  cache_key_parameters    = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "api_gateway_jobsdb_resource" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  parent_id   = aws_api_gateway_resource.deployment_name_resource[0].id
  path_part   = "jobs-db"
}

resource "aws_api_gateway_resource" "api_gateway_jobsdb_proxy_resource" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  parent_id   = aws_api_gateway_resource.api_gateway_jobsdb_resource[0].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "api_gateway_jobsdb_proxy_method" {
  count         = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id   = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  resource_id   = aws_api_gateway_resource.api_gateway_jobsdb_proxy_resource[0].id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = data.aws_ssm_parameter.api_gateway_rest_api_lambda_authorizer_id[0].value

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_jobsdb_proxy_integration" {
  count                   = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id             = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  resource_id             = aws_api_gateway_resource.api_gateway_jobsdb_proxy_resource[0].id
  http_method             = aws_api_gateway_method.api_gateway_jobsdb_proxy_method[0].http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_lb.jobsdb-load-balancer.dns_name}:${var.service_port_map.jobs_es}/{proxy}"
  cache_key_parameters    = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# Deployment resource, to enable updating a deployment when a dependent resource changes see:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment#triggers
resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  count       = var.add_routes_to_api_gateway ? 1 : 0
  rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    region      = var.region
    venue       = var.venue
    rest_api_id = data.aws_ssm_parameter.api_gateway_rest_api_id[0].value
    redployment = sha1(jsonencode([
      aws_api_gateway_resource.api_gateway_ades_wpst_resource[0],
      aws_api_gateway_resource.api_gateway_sps_api_resource[0],
      aws_api_gateway_resource.api_gateway_jobsdb_resource[0]
    ]))
  }
  depends_on = [
    aws_api_gateway_integration.api_gateway_ades_wpst_proxy_integration[0]
  ]

  # Creates a new deployment and sets the stage to use it, this allows terraform to delete this deployment object. Without this step,
  # attempts to delete the deployment may fail because the stage is still associated with it.
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
aws apigateway update-stage --region ${self.triggers.region} --rest-api-id ${self.triggers.rest_api_id} \
--stage-name=${self.triggers.venue} --patch-operations op='replace',path='/deploymentId',value=\
$(aws apigateway create-deployment --rest-api-id ${self.triggers.rest_api_id} --region ${self.triggers.region} | jq -r .id)
EOF
  }
  /*
  depends_on = [
    aws_api_gateway_integration.api_gateway_ades_wpst_proxy_integration,
    aws_api_gateway_integration.api_gateway_sps_api_proxy_integration
  ]
  */
}

resource "null_resource" "api_gateway_stage_update_resource" {
  count = var.add_routes_to_api_gateway ? 1 : 0
  provisioner "local-exec" {
    command = "aws apigateway update-stage --region ${var.region} --rest-api-id ${data.aws_ssm_parameter.api_gateway_rest_api_id[0].value} --stage-name=${var.venue} --patch-operations op='replace',path='/deploymentId',value='${aws_api_gateway_deployment.api_gateway_deployment[0].id}'"
  }
}
