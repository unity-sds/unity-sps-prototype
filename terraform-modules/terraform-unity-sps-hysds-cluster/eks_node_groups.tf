# resource "random_uuid" "boundary_uuid" {}

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

data "aws_launch_template" "default_group_node_group" {
  name = var.default_group_node_group_launch_template_name
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
    Name      = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroupIAMRole-${local.counter}"
    Component = "EKS"
    Stack     = "EKS"
  })
}

resource "aws_iam_role_policy_attachment" "eks_verdi_node_role_managed_policies" {
  for_each   = toset(local.aws_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.eks_verdi_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_verdi_node_role_customer_policies" {
  for_each   = toset(local.customer_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.eks_verdi_node_role.name
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# data "aws_security_groups" "sps-cluster-sg" {
#   # filter {
#   #   name   = "vpc-id"
#   #   values = [data.aws_eks_cluster.sps-cluster.vpc_config[0].vpc_id]
#   # }
#   filter {
#     name   = "tag:aws:eks:cluster-name"
#     values = [var.eks_cluster_name]
#   }
# }

# resource "aws_launch_template" "verdi_node_group_launch_template" {
#   name = "${var.project}-${var.venue}-${var.service_area}-EC2-VerdiNodeGroupLaunchTemplate"
#   # name_prefix = "${var.project}-${var.venue}-${var.service_area}-EC2-VerdiNodeGroupLaunchTemplate"

#   # image_id    = "ami-0ccc65ecd1024bf4c" # Test
#   image_id = "ami-0886544fa915698f0" # Dev

#   block_device_mappings {
#     device_name = "/dev/xvda"

#     ebs {
#       encrypted   = false
#       iops        = 3000
#       throughput  = 125
#       volume_size = "80"
#       volume_type = "gp3"
#     }
#   }

#   # vpc_security_group_ids = ["sg-0c41c3e5e6a999a13"] # get from the EKS cluster
#   vpc_security_group_ids = data.aws_security_groups.sps-cluster-sg.ids

#   user_data = base64encode(<<-EOF
#     MIME-Version: 1.0
#     Content-Type: multipart/mixed;
#     boundary=${random_uuid.boundary_uuid.result}

#     --${random_uuid.boundary_uuid.result}
#     Content-Type: text/x-shellscript
#     Content-Type: charset="us-ascii"

#     #!/bin/bash
#     /etc/eks/bootstrap.sh ${data.aws_eks_cluster.sps-cluster.name}

#     --${random_uuid.boundary_uuid.result}--
#     EOF
#   )

#   # Add your tags for EC2 instances here
#   tag_specifications {
#     resource_type = "instance"
#     tags = merge(local.common_tags, {
#       # Add or overwrite specific tags for this resource
#       Name      = "${var.project}-${var.venue}-${var.service_area}-EC2-VerdiNodeGroupLaunchTemplate"
#       Component = "EC2"
#       Stack     = "EC2"
#     })
#   }
#   # Add your tags for EBS volumes here
#   tag_specifications {
#     resource_type = "volume"
#     tags = merge(local.common_tags, {
#       # Add or overwrite specific tags for this resource
#       Name      = "${var.project}-${var.venue}-${var.service_area}-EBS-VerdiNodeGroupLaunchTemplate"
#       Component = "EBS"
#       Stack     = "EBS"
#     })
#   }
# }

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Create the Verdi node group in the existing EKS cluster
resource "aws_eks_node_group" "verdi" {
  cluster_name    = data.aws_eks_cluster.sps-cluster.name
  node_group_name = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroup"
  node_role_arn   = aws_iam_role.eks_verdi_node_role.arn
  subnet_ids      = tolist(data.aws_subnets.eks_subnets.ids) # TODO maybe try subsetting the IDs included here

  capacity_type  = var.verdi_node_group_capacity_type
  instance_types = var.verdi_node_group_instance_types
  scaling_config {
    desired_size = var.verdi_node_group_scaling_config.desired_size
    min_size     = var.verdi_node_group_scaling_config.min_size
    max_size     = var.verdi_node_group_scaling_config.max_size
  }
  launch_template {
    # TODO Debug why my launch template won't work
    # id      = aws_launch_template.verdi_node_group_launch_template.id
    # version = aws_launch_template.verdi_node_group_launch_template.latest_version
    id      = data.aws_launch_template.default_group_node_group.id
    version = data.aws_launch_template.default_group_node_group.latest_version
  }
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroup"
    Component = "EKS"
    Stack     = "EKS"
  })
  depends_on = [
    aws_iam_role_policy_attachment.eks_verdi_node_role_managed_policies,
    aws_iam_role_policy_attachment.eks_verdi_node_role_customer_policies,
  ]
}

resource "aws_iam_role" "eks_sps_api_node_role" {
  name = "${var.project}-${var.venue}-${var.service_area}-EKS-SPSAPINodeGroupIAMRole-${local.counter}"
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
    Name      = "${var.project}-${var.venue}-${var.service_area}-EKS-SPSAPINodeGroupIAMRole-${local.counter}"
    Component = "EKS"
    Stack     = "EKS"
  })
}

resource "aws_iam_policy" "eks_sps_api_policy" {
  name        = "${var.project}-${var.venue}-${var.service_area}-EKS-SPSAPINodeGroupScalingActions-${local.counter}"
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
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/*",
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:nodegroup/*/${var.project}-${var.venue}-${var.service_area}-EKS-VerdiNodeGroup/*",
        ],
      }
    ]
  })
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-EKS-SPSAPINodeGroupScalingActions-${local.counter}"
    Component = "EKS"
    Stack     = "EKS"
  })
}

resource "aws_iam_role_policy_attachment" "eks_sps_api_node_role_managed_policies" {
  for_each   = toset(local.aws_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.eks_sps_api_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_sps_api_node_role_customer_policies" {
  for_each   = toset(local.customer_managed_policies)
  policy_arn = each.value
  role       = aws_iam_role.eks_sps_api_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_sps_api_node_group_scaling_policy" {
  policy_arn = aws_iam_policy.eks_sps_api_policy.arn
  role       = aws_iam_role.eks_sps_api_node_role.name
}

# Create the SPS API node group in the existing EKS cluster
resource "aws_eks_node_group" "sps_api" {
  cluster_name    = data.aws_eks_cluster.sps-cluster.name
  node_group_name = "${var.project}-${var.venue}-${var.service_area}-EKS-SPSAPINodeGroup"
  node_role_arn   = aws_iam_role.eks_sps_api_node_role.arn
  subnet_ids      = tolist(data.aws_subnets.eks_subnets.ids)

  capacity_type  = "ON_DEMAND"
  instance_types = ["m5.xlarge"]
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }
  launch_template {
    id      = data.aws_launch_template.default_group_node_group.id
    version = data.aws_launch_template.default_group_node_group.latest_version
  }
  tags = merge(local.common_tags, {
    # Add or overwrite specific tags for this resource
    Name      = "${var.project}-${var.venue}-${var.service_area}-EKS-SPSAPINodeGroup"
    Component = "EKS"
    Stack     = "EKS"
  })
  depends_on = [
    aws_iam_role_policy_attachment.eks_sps_api_node_role_managed_policies,
    aws_iam_role_policy_attachment.eks_sps_api_node_role_customer_policies,
    aws_iam_role_policy_attachment.eks_sps_api_node_group_scaling_policy,
  ]
}
