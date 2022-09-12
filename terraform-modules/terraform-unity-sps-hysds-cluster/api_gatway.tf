resource "aws_ssm_parameter" "update_ades_wpst_url_stage_variable_of_api_gateway" {
  name       = format("/unity/dev/%s-%s/api-gateway/stage-variables/ades-wpst-url", var.namespace, var.counter)
  type       = "String"
  value      = "${kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname}:5001"
  overwrite  = true
  depends_on = [kubernetes_service.ades-wpst-api-service]
}

resource "aws_ssm_parameter" "update_grq_es_url_stage_variable_of_api_gateway" {
  name       = format("/unity/dev/%s-%s/api-gateway/stage-variables/grq-es-url", var.namespace, var.counter)
  type       = "String"
  value      = "${data.kubernetes_service.grq-es.status[0].load_balancer[0].ingress[0].hostname}:9201"
  overwrite  = true
  depends_on = [data.kubernetes_service.grq-es]
}

resource "aws_ssm_parameter" "update_grq_rest_api_url_stage_variable_of_api_gateway" {
  name       = format("/unity/dev/%s-%s/api-gateway/stage-variables/grq-rest-api-url", var.namespace, var.counter)
  type       = "String"
  value      = "${kubernetes_service.grq2-service.status[0].load_balancer[0].ingress[0].hostname}:8878"
  overwrite  = true
  depends_on = [kubernetes_service.grq2-service]
}

resource "aws_ssm_parameter" "update_hysds_ui_url_stage_variable_of_api_gateway" {
  name       = format("/unity/dev/%s-%s/api-gateway/stage-variables/hysds-ui-url", var.namespace, var.counter)
  type       = "String"
  value      = "${kubernetes_service.hysds-ui-service.status[0].load_balancer[0].ingress[0].hostname}:3000"
  overwrite  = true
  depends_on = [kubernetes_service.hysds-ui-service]
}

resource "aws_ssm_parameter" "update_mozart_es_url_stage_variable_of_api_gateway" {
  name       = format("/unity/dev/%s-%s/api-gateway/stage-variables/mozart-es-url", var.namespace, var.counter)
  type       = "String"
  value      = "${data.kubernetes_service.mozart-es.status[0].load_balancer[0].ingress[0].hostname}:9200"
  overwrite  = true
  depends_on = [data.kubernetes_service.mozart-es]
}

resource "aws_ssm_parameter" "update_mozart_rest_api_url_stage_variable_of_api_gateway" {
  name       = format("/unity/dev/%s-%s/api-gateway/stage-variables/mozart-rest-api-url", var.namespace, var.counter)
  type       = "String"
  value      = "${kubernetes_service.mozart-service.status[0].load_balancer[0].ingress[0].hostname}:8888"
  overwrite  = true
  depends_on = [kubernetes_service.mozart-service]
}
