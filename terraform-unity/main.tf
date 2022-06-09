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
  container_registry  = var.container_registry
  docker_images       = var.docker_images
  service_type        = var.service_type
  node_port_map       = var.node_port_map
  mozart_es           = var.mozart_es
}
