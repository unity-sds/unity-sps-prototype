output "load_balancer_hostnames" {
  description = "Load Balancer Ingress Hostnames"
  value = {
    mozart_es = module.unity-sps-hysds-cluster.load_balancer_hostnames.mozart_es
    grq_es    = module.unity-sps-hysds-cluster.load_balancer_hostnames.grq_es
    ades_wpst = module.unity-sps-hysds-cluster.load_balancer_hostnames.ades_wpst_api
  }
}
