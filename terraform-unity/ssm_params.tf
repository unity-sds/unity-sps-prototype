data "aws_ssm_parameter" "ghcr_pat" {
  name = format("/%s-%s-%s-deployment-ghcr_pat", var.project == null ? data.aws_ssm_parameter.account_project[0].value : var.project, var.venue == null ? data.aws_ssm_parameter.account_venue[0].value : var.venue, var.service_area)
}
data "aws_ssm_parameter" "uds_staging_bucket" {
  name = format("/%s-%s-%s-deployment-uds_staging_bucket", var.project == null ? data.aws_ssm_parameter.account_project[0].value : var.project, var.venue == null ? data.aws_ssm_parameter.account_venue[0].value : var.venue, var.service_area)
}
data "aws_ssm_parameter" "uds_client_id" {
  name = format("/%s-%s-%s-deployment-uds_client_id", var.project == null ? data.aws_ssm_parameter.account_project[0].value : var.project, var.venue == null ? data.aws_ssm_parameter.account_venue[0].value : var.venue, var.service_area)
}
data "aws_ssm_parameter" "uds_dapa_api" {
  name = format("/%s-%s-%s-deployment-uds_dapa_api", var.project == null ? data.aws_ssm_parameter.account_project[0].value : var.project, var.venue == null ? data.aws_ssm_parameter.account_venue[0].value : var.venue, var.service_area)
}

data "aws_ssm_parameter" "default_group_node_group_launch_template_name" {
  count = var.default_group_node_group_launch_template_name == null ? 1 : 0
  name  = "/unity/extensions/eks/${var.eks_cluster_name}/nodeGroups/default/launchTemplateName"
}

data "aws_ssm_parameter" "default_node_group_name" {
  count = var.default_group_node_group_name == null ? 1 : 0
  name  = "/unity/extensions/eks/${var.eks_cluster_name}/nodeGroups/default/name"
}

data "aws_ssm_parameter" "eks_private_subnets" {
  count = var.elb_subnets == null ? 1 : 0
  name  = "/unity/extensions/eks/${var.eks_cluster_name}/networking/subnets/privateIds"
}

data "aws_ssm_parameter" "uads_development_efs_fsmt_id" {
  count = var.uads_development_efs_fsmt_id == null ? 1 : 0
  name  = "/unity/ads/efs/development/fsmtId"
}

data "aws_ssm_parameter" "account_venue" {
  count = var.venue == null ? 1 : 0
  name  = "/unity/account/venue"
}

data "aws_ssm_parameter" "account_project" {
  count = var.project == null ? 1 : 0
  name  = "/unity/account/project"
}