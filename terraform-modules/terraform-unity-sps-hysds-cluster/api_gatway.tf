resource "aws_ssm_parameter" "update_ades_wpst_url_stage_variable_of_api_gateway" {
  name  = format("/%s/%s/%s-%s/api-gateway/stage-variables/ades-wpst-url", var.project, var.venue, var.namespace, var.counter)
  type  = "String"
  value = "${kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname}:${var.service_port_map.ades_wpst_api_service}"
  # value      = "${aws_elb.ades_wpst_api_elb.dns_name}:${var.service_port_map.ades_wpst_api_service}"
  overwrite  = true
  depends_on = [kubernetes_service.ades-wpst-api-service]
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-Deployment-ADESWPSTURL"
    Component = "Deployment"
    Stack     = "Deployment"
  })
}
