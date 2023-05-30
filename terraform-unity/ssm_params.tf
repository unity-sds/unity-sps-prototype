data "aws_ssm_parameter" "ghcr_pat" {
  name = format("/%s-%s-%s-deployment-ghcr_pat", data.aws_ssm_parameter.account_project.value, data.aws_ssm_parameter.account_venue.value, var.service_area)
}
data "aws_ssm_parameter" "uds_staging_bucket" {
  name = format("/%s-%s-%s-deployment-uds_staging_bucket", data.aws_ssm_parameter.account_project.value, data.aws_ssm_parameter.account_venue.value, var.service_area)
}
data "aws_ssm_parameter" "uds_client_id" {
  name = format("/%s-%s-%s-deployment-uds_client_id", data.aws_ssm_parameter.account_project.value, data.aws_ssm_parameter.account_venue.value, var.service_area)
}
data "aws_ssm_parameter" "uds_dapa_api" {
  name = format("/%s-%s-%s-deployment-uds_dapa_api", data.aws_ssm_parameter.account_project.value, data.aws_ssm_parameter.account_venue.value, var.service_area)
}

data "aws_ssm_parameter" "default_group_node_group_launch_template_name" {
  count = var.default_group_node_group_launch_template_name != null ? 1 : 0
  name = "/unity/extensions/eks/${var.eks_cluster_name}/nodeGroups/default/launchTemplateName"
}

data "aws_ssm_parameter" "default_node_group_name" {
  count = var.default_node_group_name != null ? 1 : 0
  name = "/unity/extensions/eks/${var.eks_cluster_name}/nodeGroups/default/name"
}

data "aws_ssm_parameter" "eks_private_subnets" {
  count = var.eks_private_subnets != null ? 1 : 0
  name = "/unity/extensions/eks/${var.eks_cluster_name}/networking/subnets/privateIds"
}

data "aws_ssm_parameter" "uads_development_efs_fsmt_id" {
  count = var.uads_development_efs_fsmt_id != null ? 1 : 0
  name = "/unity/ads/efs/development/fsmtId"
}

data "aws_ssm_parameter" "account_venue" {
  count = var.venue != null ? 1 : 0
  name = "/unity/account/venue"
}

data "aws_ssm_parameter" "account_project" {
  count = var.project != null ? 1 : 0
  name = "/unity/account/project"
}
