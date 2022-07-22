
output "load_balancer_hostnames" {
  description = "Load Balancer Ingress Hostnames"
  value       = <<-EOT
        Load Balancer Ingress Hostnames:
        HySDS UI: ${module.unity-sps-hysds-cluster.hysds_ui_load_balancer_hostname}
        Mozart: ${module.unity-sps-hysds-cluster.mozart_load_balancer_hostname}
        GRQ:  ${module.unity-sps-hysds-cluster.grq_load_balancer_hostname}
        ADES WPST API:  ${module.unity-sps-hysds-cluster.ades_wpst_api_load_balancer_hostname}
        RabbitMQ MGMT: ${module.unity-sps-hysds-cluster.rabbitmq_mgmt_load_balancer_hostname}
        RabbitMQ:  ${module.unity-sps-hysds-cluster.rabbitmq_load_balancer_hostname}
        Redis: ${module.unity-sps-hysds-cluster.redis_load_balancer_hostname}
        Minio: ${module.unity-sps-hysds-cluster.minio_load_balancer_hostname}
        EOT
}
