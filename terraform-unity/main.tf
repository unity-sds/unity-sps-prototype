# Terraform driver to instantiate the Unity SPS cluster in the cloud.
# Uses the following as a template:
# https://github.jpl.nasa.gov/EURC-SDS/pcs-cws/blob/master/terraform/sds/sds-cws-console/main.tf

# https://learn.hashicorp.com/tutorials/terraform/module-private-registry-share?in=terraform/modules
# https://www.terraform.io/language/modules/syntax

module "unity-sps-hysds-cluster" {
  source                          = "./modules/terraform-unity-sps-hysds-cluster"
  release                         = var.release
  project                         = var.project == null ? data.aws_ssm_parameter.account_project[0].value : var.project
  namespace                       = var.namespace
  venue                           = var.venue == null ? data.aws_ssm_parameter.account_venue[0].value : var.venue
  region                          = var.region
  counter                         = var.counter
  kubeconfig_filepath             = var.kubeconfig_filepath
  docker_images                   = var.docker_images
  service_type                    = var.service_type
  service_port_map                = var.service_port_map
  celeryconfig_filename           = var.celeryconfig_filename
  datasets_filename               = var.datasets_filename
  container_registry_server       = var.container_registry_server
  container_registry_username     = var.container_registry_username
  container_registry_pat          = data.aws_ssm_parameter.ghcr_pat.value
  container_registry_owner        = var.container_registry_owner
  uds_staging_bucket              = data.aws_ssm_parameter.uds_staging_bucket.value
  uds_client_id                   = data.aws_ssm_parameter.uds_client_id.value
  uds_dapa_api                    = data.aws_ssm_parameter.uds_dapa_api.value
  uads_development_efs_fsmt_id    = var.uads_development_efs_fsmt_id == null ? data.aws_ssm_parameter.uads_development_efs_fsmt_id[0].value : var.uads_development_efs_fsmt_id
  eks_cluster_name                = var.eks_cluster_name
  elb_subnets                     = var.elb_subnets == null ? data.aws_ssm_parameter.eks_private_subnets[0].value : var.elb_subnets
  default_group_node_group_name   = var.default_group_node_group_name == null ? data.aws_ssm_parameter.default_node_group_name[0].value : var.default_group_node_group_name
  deployment_name                 = var.deployment_name
  verdi_node_group_capacity_type  = var.verdi_node_group_capacity_type
  verdi_node_group_scaling_config = var.verdi_node_group_scaling_config
  verdi_node_group_instance_types = var.verdi_node_group_instance_types
  add_routes_to_api_gateway       = var.add_routes_to_api_gateway
  tags                            = var.tags
}
