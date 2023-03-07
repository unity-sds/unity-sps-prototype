# Terraform driver to instantiate the Unity SPS cluster in the cloud.
# Uses the following as a template:
# https://github.jpl.nasa.gov/EURC-SDS/pcs-cws/blob/master/terraform/sds/sds-cws-console/main.tf

# https://learn.hashicorp.com/tutorials/terraform/module-private-registry-share?in=terraform/modules
# https://www.terraform.io/language/modules/syntax

module "unity-sps-hysds-cluster" {
  source = "../terraform-modules/terraform-unity-sps-hysds-cluster"
  # source                      = "git::https://github.com/unity-sds/unity-sps-prototype.git//terraform-modules/terraform-unity-sps-hysds-cluster?ref=main"
  project                      = var.project
  namespace                    = var.namespace
  venue                        = var.venue
  region                       = var.region
  counter                      = var.counter
  kubeconfig_filepath          = var.kubeconfig_filepath
  docker_images                = var.docker_images
  service_type                 = var.service_type
  service_port_map             = var.service_port_map
  celeryconfig_filename        = var.celeryconfig_filename
  datasets_filename            = var.datasets_filename
  deployment_environment       = var.deployment_environment
  container_registry_server    = var.container_registry_server
  container_registry_username  = var.container_registry_username
  container_registry_pat       = data.aws_ssm_parameter.ghcr_pat.value
  container_registry_owner     = var.container_registry_owner
  uds_staging_bucket           = data.aws_ssm_parameter.uds_staging_bucket.value
  uds_client_id                = data.aws_ssm_parameter.uds_client_id.value
  uds_dapa_api                 = data.aws_ssm_parameter.uds_dapa_api.value
  uads_development_efs_fsmt_id = var.uads_development_efs_fsmt_id
  eks_cluster_name             = var.eks_cluster_name
}
