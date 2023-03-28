
# Data source to get existing node group information
data "aws_eks_node_group" "default_group_node_group" {
  cluster_name    = var.eks_cluster_name
  node_group_name = var.default_group_node_group_name
}

# Data source to get existing IAM role
data "aws_iam_role" "default_group_node_group_role" {
  name = element(split("/", data.aws_eks_node_group.default_group_node_group.node_role_arn), 1)
}

data "aws_launch_template" "default_group_node_group" {
  name = var.default_group_node_group_launch_template_name
}


# Create the VerdiNodeGroup in the existing EKS cluster
resource "aws_eks_node_group" "verdi_node_group" {
  cluster_name    = data.aws_eks_cluster.sps-cluster.name
  node_group_name = var.verdi_node_group_name
  node_role_arn   = data.aws_eks_node_group.default_group_node_group.node_role_arn
  subnet_ids      = tolist(data.aws_subnets.eks_subnets.ids)

  capacity_type  = var.verdi_node_group_capacity_type
  instance_types = var.verdi_node_group_instance_types
  scaling_config {
    desired_size = var.verdi_node_group_scaling_config.desired_size
    min_size     = var.verdi_node_group_scaling_config.min_size
    max_size     = var.verdi_node_group_scaling_config.max_size
  }
  launch_template {
    id      = data.aws_launch_template.default_group_node_group.id
    version = data.aws_launch_template.default_group_node_group.latest_version
  }

  tags = {
    "alpha.eksctl.io/nodegroup-name" = var.verdi_node_group_name
    "alpha.eksctl.io/nodegroup-type" = "managed"
  }
  labels = {
    "alpha.eksctl.io/nodegroup-name" = var.verdi_node_group_name
    "alpha.eksctl.io/cluster-name"   = var.eks_cluster_name
  }
}


# Create the IAM policy for EKS node group management
resource "aws_iam_policy" "eks_verdi_node_group_policy" {
  name        = "EKSVerdiNodeGroupPolicy"
  description = "Policy to allow specific EKS node group actions for Verdi worker scaling"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "eks:DescribeNodegroup",
          "eks:DescribeUpdate",
          "eks:UpdateNodegroupConfig"
        ]
        Resource = [
          data.aws_eks_cluster.sps-cluster.arn,
          aws_eks_node_group.verdi_node_group.arn
        ]
      }
    ]
  })
}

# Attach the IAM policy to the existing IAM role
resource "aws_iam_role_policy_attachment" "eks_nodegroup_policy_attachment" {
  policy_arn = aws_iam_policy.eks_verdi_node_group_policy.arn
  role       = data.aws_iam_role.default_group_node_group_role.name
}
