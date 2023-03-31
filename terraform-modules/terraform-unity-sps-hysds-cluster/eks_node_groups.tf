locals {
  aws_managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
  customer_managed_policies = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/DatalakeKinesisPolicy",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/McpToolsAccessPolicy"
  ]
}

resource "aws_iam_role" "eks_verdi_node_role" {
  name = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroupIAMRole-${local.counter}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/mcp-tenantOperator-AMI-APIG"

  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroupIAMRole"
    Component = "EKS"
    Stack     = "EKS"
  })
}

resource "aws_iam_policy" "eks_verdi_node_group_policy" {
  name        = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroupIAMPolicy-${local.counter}"
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
        ],
      }
    ]
  })
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroupIAMPolicy"
    Component = "EKS"
    Stack     = "EKS"
  })
}

resource "aws_iam_role_policy_attachment" "attach_aws_managed_policies" {
  for_each   = toset(local.aws_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.eks_verdi_node_role.name
}

resource "aws_iam_role_policy_attachment" "attach_customer_managed_policies" {
  for_each   = toset(local.customer_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.eks_verdi_node_role.name
}

resource "aws_iam_role_policy_attachment" "attach_eks_verdi_node_group_policy" {
  policy_arn = aws_iam_policy.eks_verdi_node_group_policy.arn
  role       = aws_iam_role.eks_verdi_node_role.name
}

# Data source to get existing node group information
data "aws_eks_node_group" "default_group_node_group" {
  cluster_name    = var.eks_cluster_name
  node_group_name = var.default_group_node_group_name
}


data "aws_launch_template" "default_group_node_group" {
  name = var.default_group_node_group_launch_template_name
}

# Create the VerdiNodeGroup in the existing EKS cluster
resource "aws_eks_node_group" "verdi_node_group" {
  cluster_name    = data.aws_eks_cluster.sps-cluster.name
  node_group_name = var.verdi_node_group_name
  node_role_arn   = aws_iam_role.eks_verdi_node_role.arn

  subnet_ids = tolist(data.aws_subnets.eks_subnets.ids)

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
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name                             = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroup"
    Component                        = "EKS"
    Stack                            = "EKS"
    "alpha.eksctl.io/nodegroup-name" = var.verdi_node_group_name
    "alpha.eksctl.io/nodegroup-type" = "managed"
  })
  labels = {
    "alpha.eksctl.io/nodegroup-name" = var.verdi_node_group_name
    "alpha.eksctl.io/cluster-name"   = var.eks_cluster_name
  }
  depends_on = [
    aws_iam_role_policy_attachment.attach_aws_managed_policies,
    aws_iam_role_policy_attachment.attach_customer_managed_policies,
  ]
}
