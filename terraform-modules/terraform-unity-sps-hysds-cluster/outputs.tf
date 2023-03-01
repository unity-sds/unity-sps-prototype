data "kubernetes_service" "grq-es" {
  metadata {
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    name      = jsondecode(helm_release.grq2-es.metadata[0].values).masterService
  }
}

data "kubernetes_service" "mozart-es" {
  metadata {
    namespace = kubernetes_namespace.unity-sps.metadata[0].name
    name      = jsondecode(helm_release.mozart-es.metadata[0].values).masterService
  }
}

output "load_balancer_hostnames" {
  description = "Load Balancer Ingress Hostnames"
  value = {
    mozart_es     = data.kubernetes_service.mozart-es.status[0].load_balancer[0].ingress[0].hostname,
    grq_es        = data.kubernetes_service.grq-es.status[0].load_balancer[0].ingress[0].hostname,
    ades_wpst_api = kubernetes_service.ades-wpst-api-service.status[0].load_balancer[0].ingress[0].hostname,
  }
}
