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
  name = "/unity/extensions/kubernetes/${var.eks_cluster_name}/nodeGroups/default/launchTemplateName"
}

data "aws_ssm_parameter" "default_node_group_name" {
  name = "/unity/extensions/kubernetes/${var.eks_cluster_name}/nodeGroups/default/name"
}

data "aws_ssm_parameter" "eks_private_subnets" {
  name = "/unity/extensions/kubernetes/${var.eks_cluster_name}/networking/subnets/privateIds"
}

data "aws_ssm_parameter" "uads_development_efs_fsmt_id" {
  name = "/unity/ads/efs/development/fsmtId"
}

data "aws_ssm_parameter" "account_venue" {
  name = "/unity/account/venue"
}

data "aws_ssm_parameter" "account_project" {
  name = "/unity/account/project"
}
