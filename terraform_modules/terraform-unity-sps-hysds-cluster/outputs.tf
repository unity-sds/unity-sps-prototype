output "ades_wpst_api_load_balancer_hostname" {
  description = "ADES WPST API Load Balancer Hostname"
  value       = kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname
}
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html
output "grq_load_balancer_hostname" {
  description = "value"
  value       = kubernetes_service.grq2_service.status[0].load_balancer[0].ingress[0].hostname
}

output "hysds_ui_load_balancer_hostname" {
  description = "value"
  value       = kubernetes_service.hysds-ui-service.status[0].load_balancer[0].ingress[0].hostname
}

output "minio_load_balancer_hostname" {
  description = "value"
  value       = kubernetes_service.minio-service.status[0].load_balancer[0].ingress[0].hostname
}

output "rabbitmq_mgmt_load_balancer_hostname" {
  description = "value"
  value       = kubernetes_service.rabbitmq-mgmt-service.status[0].load_balancer[0].ingress[0].hostname
}

output "rabbitmq_load_balancer_hostname" {
  description = "value"
  value       = kubernetes_service.rabbitmq-service.status[0].load_balancer[0].ingress[0].hostname
}

output "mozart_load_balancer_hostname" {
  description = "value"
  value       = kubernetes_service.mozart-service.status[0].load_balancer[0].ingress[0].hostname
}

output "redis_load_balancer_hostname" {
  description = "value"
  value       = kubernetes_service.redis_service.status[0].load_balancer[0].ingress[0].hostname
}
