data "aws_ssm_parameter" "default_node_group_name" {
  count = var.default_group_node_group_name == null ? 1 : 0
  name  = "/unity/extensions/eks/${var.eks_cluster_name}/nodeGroups/default/name"
}

data "aws_ssm_parameter" "eks_private_subnets" {
  count = var.elb_subnets == null ? 1 : 0
  name  = "/unity/extensions/eks/${var.eks_cluster_name}/networking/subnets/publicIds"
}

data "aws_ssm_parameter" "uads_development_efs_fsmt_id" {
  count = var.uads_development_efs_fsmt_id == null ? 1 : 0
  name  = "/unity/ads/efs/development/fsmtId"
}
