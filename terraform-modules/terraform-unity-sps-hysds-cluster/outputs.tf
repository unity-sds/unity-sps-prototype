# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html

output "load_balancer_hostnames" {
  description = "Load Balancer Ingress Hostnames"
  value = {
    mozart_es     = data.kubernetes_service.mozart-es.status[0].load_balancer[0].ingress[0].hostname,
    grq_es        = data.kubernetes_service.grq-es.status[0].load_balancer[0].ingress[0].hostname,
    ades_wpst_api = kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname,
    sps_api       = kubernetes_service.sps-api-service.status[0].load_balancer[0].ingress[0].hostname,
  }
}
