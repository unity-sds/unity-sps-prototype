# Terraform driver to instantiate the Unity SPS cluster in the cloud.
# Uses the following as a template:
# https://github.jpl.nasa.gov/EURC-SDS/pcs-cws/blob/master/terraform/sds/sds-cws-console/main.tf

# https://learn.hashicorp.com/tutorials/terraform/module-private-registry-share?in=terraform/modules
# https://www.terraform.io/language/modules/syntax

module "unity-sps-hysds-cluster" {
  source = "../terraform_modules/terraform-unity-sps-hysds-cluster"
  # source                      = "git::https://github.com/unity-sds/unity-sps-prototype.git//terraform_modules/terraform-unity-sps-hysds-cluster?ref=main"
  namespace           = var.namespace
  kubeconfig_filepath = var.kubeconfig_filepath
  docker_images       = var.docker_images
  service_type        = var.service_type
  node_port_map       = var.node_port_map
  mozart_es           = var.mozart_es
}

output "load_balancer_hostnames" {
  value = <<-EOT
    Load Balancer Ingress Hostnames:
    HySDS UI: ${module.unity-sps-hysds-cluster.hysds-ui-load-balancer-hostname}
    Mozart: ${module.unity-sps-hysds-cluster.mozart-load-balancer-hostname}
    GRQ:  ${module.unity-sps-hysds-cluster.grq-load-balancer-hostname}
    ADES WPST API:  ${module.unity-sps-hysds-cluster.ades-wpst-api-load-balancer-hostname}
    RabbitMQ MGMT: ${module.unity-sps-hysds-cluster.rabbitmq-mgmt-load-balancer-hostname}
    RabbitMQ:  ${module.unity-sps-hysds-cluster.rabbitmq-load-balancer-hostname}
    Redis: ${module.unity-sps-hysds-cluster.redis-load-balancer-hostname}
    Minio: ${module.unity-sps-hysds-cluster.minio-load-balancer-hostname}
    EOT
}
