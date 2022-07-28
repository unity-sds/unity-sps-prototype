output "load_balancer_hostnames" {
  description = "Load Balancer Ingress Hostnames"
  value       = module.unity-sps-hysds-cluster.load_balancer_hostnames
}
